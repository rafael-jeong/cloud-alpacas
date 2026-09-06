import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import OPP_AGENT_CHAT from '@salesforce/messageChannel/OpportunityAgentChat__c';
import sendMessageApex from '@salesforce/apex/OpportunityAgentChatController.sendMessage';
import endConversationApex from '@salesforce/apex/OpportunityAgentChatController.endConversation';
import USER_ID from '@salesforce/user/Id';
import MASCOT_URL from '@salesforce/resourceUrl/CA_Alpaca_Mascot';

const STORE_PREFIX = 'caOppAgentHist';
const MAX_CONVERSATIONS = 25;
const MAX_MESSAGES_PER_CONVERSATION = 60;
const TITLE_MAX = 40;

/**
 * Compact Opportunity Agent composer (Opportunity record page, rightcol).
 * Owns all transport + browser-side conversation history; delegates the wide
 * list / detail experience to c-opportunity-agent-chat-modal.
 */
export default class OpportunityAgentChat extends LightningElement {
    @api recordId;

    mascotUrl = MASCOT_URL;
    opportunityName;
    draft = '';
    busy = false;

    conversations = [];
    activeId;
    modalOpen = false;
    modalView = 'detail'; // 'list' | 'detail'
    searchTerm = '';

    // --- lifecycle -------------------------------------------------

    @wire(MessageContext) messageContext;
    _chatSub;

    connectedCallback() {
        this.conversations = this.readStore();
        this._chatSub = subscribe(this.messageContext, OPP_AGENT_CHAT, (msg) => this.handleChatSignal(msg));
    }

    disconnectedCallback() {
        if (this._chatSub) {
            unsubscribe(this._chatSub);
            this._chatSub = undefined;
        }
    }

    /**
     * Another record-page component (Stage Guidance) asked to open the Opportunity
     * Agent with a suggested question. We only open the wide modal in list view and
     * pre-fill the composer — nothing is sent until the user chooses to.
     */
    handleChatSignal(msg) {
        if (!msg || msg.action !== 'open') {
            return;
        }
        if (msg.prompt) {
            this.draft = msg.prompt;
        }
        this.conversations = this.readStore();
        this.modalView = 'list';
        this.activeId = undefined;
        this.searchTerm = '';
        this.modalOpen = true;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD] })
    wiredOpp({ data }) {
        if (data) {
            this.opportunityName = getFieldValue(data, NAME_FIELD);
        }
    }

    // --- compact card getters ------------------------------------

    get sendDisabled() {
        return this.busy || this.draft.trim().length === 0;
    }

    get sendClass() {
        return this.sendDisabled ? 'oac-send oac-send_off' : 'oac-send';
    }

    get activeConversation() {
        return this.conversations.find((c) => c.id === this.activeId) || null;
    }

    // --- compact card events ------------------------------------

    handleDraft(event) {
        this.draft = event.target.value;
    }

    handleComposerKey(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.handleAsk();
        }
    }

    handleAsk() {
        const text = this.draft.trim();
        if (!text || this.busy) {
            return;
        }
        this.draft = '';
        this.detachActiveSession();
        const convo = this.createConversation(text);
        this.activeId = convo.id;
        this.modalView = 'detail';
        this.modalOpen = true;
        this.dispatchTurn(convo.id, text);
    }

    handleOpenHistory() {
        this.conversations = this.readStore();
        this.modalView = 'list';
        this.activeId = undefined;
        this.searchTerm = '';
        this.modalOpen = true;
    }

    // --- modal events ------------------------------------------

    handleModalClose() {
        this.modalOpen = false;
    }

    handleModalBack() {
        this.modalView = 'list';
        this.activeId = undefined;
    }

    handleModalOpenConversation(event) {
        this.activeId = event.detail.id;
        this.modalView = 'detail';
    }

    handleModalNewConversation() {
        this.detachActiveSession();
        const convo = this.createConversation(null);
        this.activeId = convo.id;
        this.modalView = 'detail';
    }

    /**
     * Delete ONE saved conversation from the browser-side history. localStorage
     * only — never any Salesforce record. Other conversations, search and date
     * grouping are untouched.
     */
    handleModalDeleteConversation(event) {
        const id = event.detail && event.detail.id;
        if (!id) {
            return;
        }
        const removed = this.conversations.find((c) => c.id === id);
        const wasActive = this.activeId === id;

        this.conversations = this.conversations.filter((c) => c.id !== id);

        // Best-effort close the deleted conversation's Agent session so it can
        // never be picked up again; its transcript is gone regardless.
        if (removed && removed.sessionId) {
            Promise.resolve(endConversationApex({ sessionId: removed.sessionId })).catch(() => {});
        }

        if (wasActive) {
            this.activeId = undefined;
            this.modalView = 'list';
        }

        this.persist();
    }

    /** Server-side close the previous conversation's session; its transcript stays in history. */
    detachActiveSession() {
        const convo = this.activeConversation;
        if (convo && convo.sessionId) {
            const staleId = convo.sessionId;
            this.patchConversation(convo.id, { sessionId: null });
            this.persist();
            Promise.resolve(endConversationApex({ sessionId: staleId })).catch(() => {});
        }
    }

    handleModalSearch(event) {
        this.searchTerm = event.detail.value || '';
    }

    handleModalSend(event) {
        const text = (event.detail.text || '').trim();
        if (!text || this.busy || !this.activeId) {
            return;
        }
        this.dispatchTurn(this.activeId, text);
    }

    // --- transport ------------------------------------------------

    async dispatchTurn(conversationId, text) {
        let convo = this.conversations.find((c) => c.id === conversationId);
        if (!convo) {
            return;
        }
        convo = this.appendMessage(conversationId, 'user', text);
        if (!convo.title) {
            this.patchConversation(conversationId, { title: this.deriveTitle(text) });
        }
        this.busy = true;
        this.persist();

        try {
            const turn = await sendMessageApex({
                opportunityId: this.recordId,
                sessionId: convo.sessionId || null,
                message: text
            });
            this.patchConversation(conversationId, { sessionId: turn.sessionId });
            if (turn.sessionRestarted) {
                this.appendMessage(conversationId, 'system', '이전 Agent 세션이 만료되어 새 세션에서 이어갑니다.');
            }
            this.appendMessage(conversationId, 'agent', turn.reply);
        } catch (e) {
            const msg =
                (e && e.body && e.body.message) ||
                (e && e.message) ||
                'Agent 응답을 가져오지 못했습니다.';
            this.appendMessage(conversationId, 'error', msg);
        }
        this.busy = false;
        this.patchConversation(conversationId, { updatedAt: Date.now() });
        this.conversations = [...this.conversations].sort((a, b) => b.updatedAt - a.updatedAt);
        this.persist();
    }

    // --- conversation model (immutable — replace objects so the modal re-renders) --

    createConversation(firstText) {
        const now = Date.now();
        const convo = {
            id: `c-${now}-${Math.floor(Math.random() * 1e6)}`,
            title: firstText ? this.deriveTitle(firstText) : '',
            sessionId: null,
            createdAt: now,
            updatedAt: now,
            messages: []
        };
        this.conversations = [convo, ...this.conversations].slice(0, MAX_CONVERSATIONS);
        this.persist();
        return convo;
    }

    patchConversation(id, patch) {
        this.conversations = this.conversations.map((c) => (c.id === id ? { ...c, ...patch } : c));
        return this.conversations.find((c) => c.id === id);
    }

    appendMessage(id, role, text) {
        return this.patchConversation(id, {
            messages: [
                ...(this.conversations.find((c) => c.id === id).messages || []),
                { key: `m-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`, role, text: text || '', ts: Date.now() }
            ].slice(-MAX_MESSAGES_PER_CONVERSATION)
        });
    }

    deriveTitle(text) {
        const normalized = (text || '').replace(/\s+/g, ' ').trim();
        if (normalized.length <= TITLE_MAX) {
            return normalized || '새 대화';
        }
        return `${normalized.slice(0, TITLE_MAX)}…`;
    }

    // --- persistence (localStorage, per user + Opportunity) ----

    get storeKey() {
        return `${STORE_PREFIX}:${USER_ID || 'anon'}:${this.recordId || 'none'}`;
    }

    readStore() {
        try {
            const raw = window.localStorage.getItem(this.storeKey);
            if (!raw) {
                return [];
            }
            const parsed = JSON.parse(raw);
            const list = Array.isArray(parsed && parsed.conversations) ? parsed.conversations : [];
            return list
                .map((c) => ({
                    id: String(c.id),
                    title: c.title || '',
                    sessionId: c.sessionId || null,
                    createdAt: Number(c.createdAt) || Date.now(),
                    updatedAt: Number(c.updatedAt) || Date.now(),
                    messages: (Array.isArray(c.messages) ? c.messages : []).map((m, i) => ({
                        key: `m-${i}`,
                        role: ['user', 'agent', 'system', 'error'].includes(m.role) ? m.role : 'agent',
                        text: typeof m.text === 'string' ? m.text : '',
                        ts: Number(m.ts) || 0
                    }))
                }))
                .sort((a, b) => b.updatedAt - a.updatedAt);
        } catch (e) {
            return [];
        }
    }

    persist() {
        try {
            // Only user-visible content + identifiers. Never a token / cookie / trace.
            const payload = {
                conversations: this.conversations.slice(0, MAX_CONVERSATIONS).map((c) => ({
                    id: c.id,
                    title: c.title,
                    sessionId: c.sessionId,
                    createdAt: c.createdAt,
                    updatedAt: c.updatedAt,
                    messages: c.messages.map((m) => ({ role: m.role, text: m.text, ts: m.ts }))
                }))
            };
            window.localStorage.setItem(this.storeKey, JSON.stringify(payload));
        } catch (e) {
            // storage unavailable / quota — history stays in memory for this session
        }
    }

}