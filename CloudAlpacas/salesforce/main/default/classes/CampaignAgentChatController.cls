/**
 * Transport bridge for the embedded Campaign Agent chat (campaignAgentChat LWC).
 *
 * Cloned from OpportunityAgentChatController — see that class for the original
 * pattern and the Named Credential / auth notes below, which apply unchanged.
 *
 * This class does NOT reason about campaign execution. It only starts / continues /
 * ends an Agent API conversation and hands the agent's text back to the component.
 *
 * Authentication: the Salesforce Agent API (api.salesforce.com/einstein/ai-agent) is
 * an internal Employee Agent, so it needs a user-context SFAP token, not an app-only
 * one. That token comes from the CA_Agent_API_PerUser Named Credential — the SAME
 * Per-User OAuth (Browser Flow) External Credential already used by the Opportunity
 * Agent embed (the credential authenticates the callout as the running user; it is
 * not specific to any one agent — which agent's session gets created depends only on
 * AGENT_DEV_NAME below). The token is never handled in Apex and never sent to the
 * browser.
 *
 * Difference from the Opportunity Agent controller: Sponsorship_Campaign_Agent's
 * actions (get_bottlenecks / get_renewal_summary / adopt_mitigation) resolve records
 * by NAME (LIKE match), not by Record Id — there is no find-by-id action. The first
 * turn is therefore bound with the current Campaign's NAME, not its Record Id.
 * Sponsorship_Campaign_Agent's default_locale is already ko, so (unlike the
 * Opportunity Agent) no Korean-reply directive is needed here.
 *
 * with sharing, zero DML, callouts only.
 */
public with sharing class CampaignAgentChatController {

    private static final String AGENT_DEV_NAME = 'Sponsorship_Campaign_Agent';
    // Per-User OAuth Named Credential CA_Agent_API_PerUser -> https://api.salesforce.com.
    private static final String AGENT_API = 'callout:CA_Agent_API_PerUser/einstein/ai-agent/v1';
    private static final Integer CALLOUT_TIMEOUT_MS = 110000;

    @TestVisible
    private static String agentIdForTest;

    public class ChatTurn {
        @AuraEnabled public String sessionId;
        @AuraEnabled public String reply;
        @AuraEnabled public Boolean sessionRestarted = false;
    }

    /**
     * Send one user turn. Starts a session on the first call (blank sessionId).
     * The current Campaign's name is attached to the first turn only.
     */
    @AuraEnabled
    public static ChatTurn sendMessage(Id campaignId, String campaignName, String sessionId, String message) {
        String clean = (message == null) ? '' : message.trim();
        if (String.isBlank(clean)) {
            throwHandled('메시지를 입력하세요.');
        }

        ChatTurn turn = new ChatTurn();
        Boolean firstTurn = String.isBlank(sessionId);

        if (firstTurn) {
            sessionId = startSession();
        }

        String outbound = firstTurn ? firstTurnPreamble(campaignName, clean) : clean;

        HttpResponse res = rawPostMessage(sessionId, outbound);

        // Server-side session idle-expiry: restart once, transparently, keeping record context.
        if (res.getStatusCode() == 404 && !firstTurn) {
            sessionId = startSession();
            outbound = firstTurnPreamble(campaignName, clean);
            res = rawPostMessage(sessionId, outbound);
            turn.sessionRestarted = true;
        }

        if (res.getStatusCode() != 200) {
            throwHandled(sanitizeApiError(res, '메시지를 보내지 못했습니다.'));
        }

        turn.sessionId = sessionId;
        turn.reply = extractReply(res.getBody());
        return turn;
    }

    /** Best-effort session close. Never throws. */
    @AuraEnabled
    public static void endConversation(String sessionId) {
        if (String.isBlank(sessionId)) {
            return;
        }
        try {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(AGENT_API + '/sessions/' + sessionId);
            req.setMethod('DELETE');
            req.setHeader('x-session-end-reason', 'UserRequest');
            req.setTimeout(30000);
            new Http().send(req);
        } catch (Exception ignored) {
            // closing a stale/expired session is not an error worth surfacing
        }
    }

    // ------------------------------------------------------------------ transport

    /** First-turn context: bind the current Campaign by name, when known. */
    private static String firstTurnPreamble(String campaignName, String message) {
        if (String.isBlank(campaignName)) {
            return message;
        }
        return '(이 대화는 캠페인 \'' + campaignName + '\' 페이지에서 열렸습니다. 사용자가 다른 캠페인이나 '
            + '스폰서사를 이름으로 새로 지정하지 않는 한, 이 캠페인을 대상으로 사용하세요.)\n\n'
            + message;
    }

    private static String startSession() {
        Map<String, Object> body = new Map<String, Object>{
            'externalSessionKey' => 'campchat-' + Crypto.getRandomLong(),
            'instanceConfig' => new Map<String, Object>{ 'endpoint' => URL.getOrgDomainUrl().toExternalForm() },
            'streamingCapabilities' => new Map<String, Object>{ 'chunkTypes' => new List<String>{ 'Text' } },
            'variables' => new List<Object>(),
            'bypassUser' => false
        };
        HttpResponse res = agentApi('POST', '/agents/' + resolveAgentId() + '/sessions', JSON.serialize(body));
        if (res.getStatusCode() != 200) {
            throwHandled(sanitizeApiError(res, '대화 세션을 시작하지 못했습니다.'));
        }
        Object sid;
        try {
            sid = ((Map<String, Object>) JSON.deserializeUntyped(res.getBody())).get('sessionId');
        } catch (Exception e) {
            sid = null;
        }
        if (sid == null) {
            throwHandled('세션 ID를 받지 못했습니다.');
        }
        return String.valueOf(sid);
    }

    private static HttpResponse rawPostMessage(String sessionId, String text) {
        Map<String, Object> body = new Map<String, Object>{
            'message' => new Map<String, Object>{
                'sequenceId' => Datetime.now().getTime(),
                'type' => 'Text',
                'text' => text
            },
            'variables' => new List<Object>()
        };
        return agentApi('POST', '/sessions/' + sessionId + '/messages', JSON.serialize(body));
    }

    private static HttpResponse agentApi(String method, String path, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(AGENT_API + path);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        // Suppress Builder-only markdown so the LWC renders plain text.
        req.setHeader('x-attributed-client', 'no-builder');
        req.setHeader('x-client-name', 'ca-campaign-agent-chat');
        if (body != null) {
            req.setBody(body);
        }
        req.setTimeout(CALLOUT_TIMEOUT_MS);
        try {
            return new Http().send(req);
        } catch (System.CalloutException ce) {
            // Named Credential / External Credential problem. The platform message
            // (e.g. "Unable to fetch the OAuth token.") is a safe, actionable hint —
            // it never contains a token, secret or Authorization header.
            String reason = String.isBlank(ce.getMessage()) ? '' : ' (' + ce.getMessage() + ')';
            throwHandled('Agent API 연결에 실패했습니다. CA_Agent_API_PerUser Named Credential 인증을 확인하세요 (사용자별 승인 필요).' + reason);
        } catch (Exception e) {
            throwHandled('Agent 응답을 기다리는 중 오류가 발생했습니다.');
        }
        return null;
    }

    private static String resolveAgentId() {
        if (agentIdForTest != null) {
            return agentIdForTest;
        }
        List<BotDefinition> bots = [
            SELECT Id FROM BotDefinition WHERE DeveloperName = :AGENT_DEV_NAME LIMIT 1
        ];
        if (bots.isEmpty()) {
            throwHandled('Sponsorship_Campaign_Agent를 찾을 수 없습니다.');
        }
        return bots[0].Id;
    }

    // ------------------------------------------------------------------ response shaping

    @TestVisible
    private static String extractReply(String responseBody) {
        List<String> parts = new List<String>();
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Object msgs = parsed.get('messages');
            if (msgs instanceof List<Object>) {
                for (Object m : (List<Object>) msgs) {
                    if (m instanceof Map<String, Object>) {
                        Object txt = ((Map<String, Object>) m).get('message');
                        if (txt != null && String.isNotBlank(String.valueOf(txt))) {
                            parts.add(String.valueOf(txt));
                        }
                    }
                }
            }
        } catch (Exception e) {
            // fall through to the generic message
        }
        return parts.isEmpty() ? 'Agent가 응답 텍스트를 반환하지 않았습니다.' : String.join(parts, '\n\n');
    }

    @TestVisible
    private static String sanitizeApiError(HttpResponse res, String fallback) {
        try {
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Object msg = parsed.get('message');
            if (msg != null && String.isNotBlank(String.valueOf(msg))) {
                return fallback + ' (' + String.valueOf(msg) + ')';
            }
        } catch (Exception e) {
            // ignore — never leak a raw body / stack
        }
        return fallback + ' (' + res.getStatusCode() + ')';
    }

    private static void throwHandled(String message) {
        AuraHandledException e = new AuraHandledException(message);
        e.setMessage(message);
        throw e;
    }
}
