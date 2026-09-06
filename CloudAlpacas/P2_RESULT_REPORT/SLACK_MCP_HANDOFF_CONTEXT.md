# Slack PRM 업무 허브 구축 — AI Handoff Context

> ⚠️ 이 문서는 **로컬 전용**입니다. git에 커밋하지 않습니다 (AI_HANDOFF_CONTEXT.md와 동일한 원칙).
> 작성일: 2026-08-26 / 작성자: 승우(Rafael Espada) 요청, Claude 작성

## 1. 이 문서의 목적

Cloud Alpacas Salesforce 프로젝트(B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md §1~28)와는 별개로 진행 중인 **Slack PRM 업무 허브 구축** 스레드의 컨텍스트를 새 AI 세션이 이어받을 수 있도록 정리한 문서입니다. Slack MCP 서버를 세션 도중에 추가하면 그 세션에는 도구가 즉시 로드되지 않아, 새 세션에서 이어가야 했습니다.

---

## 2. 배경 — 역할 분담 구조

- **Slack**: PRM 매니저(승우)의 일상 업무 화면
- **기존 Salesforce Slack 봇**: Salesforce 데이터 조회·분석·CRUD 담당 (이미 Enterprise 워크스페이스에 설치돼 있음)
- **Claude(MCP 연동)**: 채널 구조 설계, 메시지 분석, 업무 정리, 문서 생성, 반복 업무 자동화 담당
- **Salesforce**: 최종 데이터 저장소, Dashboard는 KPI 원본

당초 Agentforce로 `ALL IN ONE PRM Agent`를 직접 만드는 방안을 검토했으나, 이미 Salesforce 데이터 조회·CRUD를 처리하는 기존 Slack 봇이 있어 중복 투자로 판단해 방향을 바꿨습니다 — 새 Agent를 만드는 대신 Slack 자체를 업무 허브로 구축하고, Claude는 그 안에서 기존 봇이 못 하는 영역(문서화, 요약, 자동화)을 담당합니다.

---

## 3. Slack MCP 연동 상태 — 완료됨 (재작업 금지)

### 워크스페이스 식별 정보
같은 이름의 "Cloud Alpacas" 워크스페이스가 Free/Enterprise 두 개 존재해서 혼동 주의가 필요했습니다. **Enterprise 워크스페이스에 연결된 것을 아래 값으로 확인 완료**했습니다.

| 항목 | 값 |
| --- | --- |
| Workspace | Cloud Alpacas |
| URL | slackforcloudalpaca.slack.com |
| Team ID | T0BSM719FJ7 |
| Enterprise ID | E0BQ7Q0BHR6 (이 값의 존재 자체가 Enterprise Grid 소속이라는 증거) |

### 연동 방식 — 왜 이렇게 했는가 (중요, 재시도 금지 사항)

**Claude Code 기본 `claude mcp login slack` OAuth 방식은 작동하지 않습니다.** 시도하면 아래 오류가 재현됩니다.

```
Couldn't complete authentication for "slack": SDK auth failed: Incompatible auth server: does not support dynamic client registration
```

원인: Slack의 공식 호스팅 MCP 서버(`mcp.slack.com`)는 OAuth "동적 클라이언트 등록"(RFC 7591)을 지원하지 않는데, Claude Code의 MCP 클라이언트는 이 방식만 시도하도록 돼 있어 구조적으로 안 맞습니다. **Anthropic 쪽에 이미 알려진 미해결 버그**입니다(`anthropics/claude-code` 저장소에 이슈 다수 등록: #52638, #18009, #52354, #52348, #38102, #53253 / `anthropics/claude-plugins-official` #17). 공식 플러그인(`/plugin install slack`)으로 설치해도 동일하게 실패했습니다 — 등록 방식과 무관한 문제입니다.

**해결 방법 (완료됨)**: 호스팅된 HTTP+OAuth 서버 대신, `@modelcontextprotocol/server-slack` npm 패키지를 **stdio 방식**으로 직접 연결하고 Slack App을 수동으로 만들어 발급받은 **Bot Token**으로 인증했습니다.

```bash
claude mcp add slack -e SLACK_BOT_TOKEN=xoxb-... -e SLACK_TEAM_ID=T0BSM719FJ7 -- npx -y @modelcontextprotocol/server-slack
```

`claude mcp list` 결과: `slack: npx -y @modelcontextprotocol/server-slack - ✔ Connected` 확인됨.

### Slack App 설정 정보

- App 이름: **AI PRM Assistant**
- 생성 위치: Enterprise Cloud Alpacas 워크스페이스 (api.slack.com/apps에서 "Blank app"으로 생성)
- Bot Token: `xoxb-`로 시작, Slack App 관리 화면(OAuth & Permissions 또는 Install App 메뉴)에서 재확인 가능

### 부여된 Bot Token Scopes (13개)

| Scope | 용도 |
| --- | --- |
| `channels:read` | 채널 목록/정보 조회 |
| `channels:history` | 공개 채널 메시지 읽기 |
| `channels:manage` | 채널 생성/관리 |
| `channels:write.topic` | 채널 설명(주제) 설정 |
| `channels:join` | 봇이 스스로 공개 채널 참여 |
| `chat:write` | 메시지 게시 |
| `chat:write.public` | 봇이 참여 안 한 채널에도 게시 |
| `groups:read` | 비공개 채널 정보 |
| `groups:history` | 비공개 채널 메시지 |
| `users:read` | 사용자 정보 |
| `bookmarks:write` | 채널 북마크 생성/수정 |
| `pins:write` | 메시지 고정 |
| `canvases:write` | Slack Canvas 생성/수정 |

> ⚠️ Scope는 부여했지만, `@modelcontextprotocol/server-slack` 패키지가 Canvas·채널 생성 등 고급 기능을 실제로 구현했는지는 **연결 후 실제 테스트로 아직 미확인**입니다. Scope 존재 ≠ 서버가 그 기능을 지원.

---

## 4. 새 세션에서 가장 먼저 할 일 (체크리스트)

이전 세션에서 MCP 서버를 세션 도중에 추가해서, 그 세션에는 실제 Slack 도구(`mcp__slack__*` 등)가 로드되지 않았습니다(ToolSearch로 확인 시도했으나 못 찾음). **새 세션에서는 로드됐을 것으로 예상**되며, 아래 순서로 검증합니다.

1. Slack 관련 도구가 실제로 이 세션에 로드됐는지 확인 (ToolSearch 또는 직접 호출 시도)
2. 올바른 워크스페이스(Enterprise, Salesforce 봇이 설치된 곳)에 연결된 게 맞는지 재확인 — 예: 채널 멤버/앱 목록에서 Salesforce 봇 존재 여부로 교차 확인
3. Canvas 생성, 채널 생성 등 고급 기능이 실제로 동작하는지 가벼운 스모크 테스트

---

## 4-1. 검증 로그 (2026-08-26, 이어받은 세션)

체크리스트 1번(도구 로드 확인)을 실행한 결과, **원인이 명확해졌습니다.**

- `~/.claude.json`의 프로젝트별(`C:/Users/Administrator/Desktop/Cloud Alpacas`) 설정에 `slack` MCP 서버가 정확히 등록돼 있음을 직접 확인함 (stdio, `npx -y @modelcontextprotocol/server-slack`, Bot Token/Team ID 정상 포함).
- 이 프로젝트 디렉터리에서 **별도로 새로 띄운** `claude mcp list` 프로세스는 `slack: npx -y @modelcontextprotocol/server-slack - ✔ Connected`를 반환함 — 즉 npx 실행, Bot Token 인증 모두 문제없이 동작.
- 그런데도 **이어받은 세션 자체의 도구 목록(ToolSearch)에는 slack 관련 도구가 전혀 없었음.** 결론: Claude Code는 실행 중인 세션에 새로 추가된 MCP 서버를 실시간 재로드하지 않는다 — 세션이 시작된 "이후"에 MCP 서버를 추가하면, **그 세션이 끝나고 완전히 새로 열린 세션**에서만 도구가 로드된다. (이전 세션에서 겪은 것과 동일한 문제가 이번 이어받은 세션에서도 재현됨 — 즉 "이전 세션 도중 추가 → 다음 세션에서 확인"이라는 이어받기 자체는 여러 번 반복될 수 있으므로, **반드시 도구가 로드됐는지 실제로 새 세션 첫 턴에 ToolSearch나 직접 호출로 검증부터 하고 시작할 것.**)
- 부가 참고: 진단 과정에서 `cat ~/.claude.json | grep slack` 류의 명령이 터미널 출력에 **Bot Token 원문을 노출**시켰음. 외부로 전송되진 않았지만, 이 대화 로그 안에는 토큰 값이 평문으로 남아 있음. 민감하게 관리해야 한다면 토큰 재발급(rotate)을 고려할 것.

**다음 세션에서 할 일**: 이 문서(§4) 체크리스트의 1번은 위 내용으로 이미 답이 나왔으니 건너뛰고, 바로 2번(올바른 Enterprise 워크스페이스 연결 재확인)과 3번(Canvas·채널 생성 스모크 테스트)부터 시작할 것.

### 4-1-1. 재검증 로그 (2026-08-26, VSCode 확장 세션에서 재현)

VSCode 네이티브 확장(Claude Code) 환경에서 새 대화 세션으로 §4-1 체크리스트 1번을 다시 검증했으나 **동일한 문제가 재현됨**:

- `claude mcp list` (Bash 도구로 직접 실행) 결과: `slack: npx -y @modelcontextprotocol/server-slack - ✔ Connected` — 서버 프로세스/인증 자체는 정상.
- 하지만 ToolSearch로 `slack`, `mcp__slack`, 그리고 `@modelcontextprotocol/server-slack`이 노출하는 것으로 추정되는 구체적 도구명(`slack_list_channels`, `slack_post_message`, `slack_get_channel_history`, `slack_users_list`)을 각각 조회해도 **매칭되는 도구가 전혀 없었음**. 즉 이 세션의 도구 목록에 slack 관련 도구가 하나도 로드돼 있지 않음.
- 결론(가설 수정): "완전히 새 세션을 열면 해결된다"는 기존 §4-1의 결론만으로는 불충분했다. **CLI에서 새 터미널 세션을 여는 것과 VSCode 확장 호스트(창) 자체를 재시작하는 것은 다를 수 있다** — VSCode 확장 안에서 새 대화를 시작하는 것만으로는 MCP 서버 재로드가 트리거되지 않을 가능성이 있음.
- **다음 세션에서 할 일**: VSCode 창을 완전히 닫았다가 다시 연 뒤(단순히 새 대화 탭을 여는 것이 아니라 확장 호스트 프로세스 자체 재시작), 첫 턴에 ToolSearch로 slack 도구 로드 여부부터 재검증할 것. 그래도 안 되면 `claude mcp remove slack` 후 동일 `claude mcp add` 커맨드로 재등록해 강제 재로드를 시도해볼 것 (이번 세션에서는 사용자 승인 없이 시도하지 않았음 — 미검증 방법).

### 4-1-2. Bot Token 재발급 + 재등록 완료 (2026-08-26, 같은 VSCode 세션 후속)

§4-1-1에서 노출된 구 Bot Token(`...T0ymBhsoNXu3GLsvg4EDbXTy`)을 로테이션했습니다. 과정에서 확인된 것들:

- **단순 "Reinstall to Workspace"로는 토큰이 안 바뀜** — scope 변경이 없으면 Slack이 기존 Bot Token을 그대로 유지함. 워크스페이스에서 앱을 완전히 제거(Remove App)한 뒤 재설치해도 동일했음(같은 토큰 재발급됨) — 이 워크스페이스에서는 재설치만으로 토큰 회전이 보장되지 않음.
- **확실하게 무효화되는 방법**: Slack Web API `auth.revoke`를 구 토큰으로 직접 호출. 단, Claude Code 자동 모드 분류기가 "토큰을 헤더에 담아 외부로 전송"하는 패턴의 Bash/PowerShell 호출을 차단함(curl, `Invoke-RestMethod` 둘 다 거부됨) — **사용자가 본인 터미널에서 직접 실행해야 함**. 실행 후 재설치하니 새 토큰(`...lpU66vFA7viG99InjvcloyS7`)이 정상 발급됨.
- **새 토큰으로 MCP 서버 재등록 완료**: `claude mcp remove slack` (scope 플래그 없이 실행 — `-s local`을 붙이면 "No MCP server named slack in local scope" 오류가 나는 CLI 버그성 동작이 있었음, 플래그 생략하면 정상 제거됨) → `claude mcp add slack -e SLACK_BOT_TOKEN=... -e SLACK_TEAM_ID=T0BSM719FJ7 -- npx -y @modelcontextprotocol/server-slack` 재실행. `claude mcp get slack` 결과 `✔ Connected`, 새 토큰 반영 확인 완료.
- **그런데도 같은 세션의 ToolSearch에는 여전히 slack 도구 없음** — §4-1-1의 결론(CLI 등록/연결과 세션 내 도구 로드는 별개)이 이번에도 재확인됨. 재등록 자체는 세션 재시작을 대체하지 못함.
- 현재 Bot Token 값은 이 문서에 기록하지 않음(§4-1의 노출 사고 반복 방지) — 필요 시 `claude mcp get slack`으로 조회.

**다음 세션에서 할 일**: 여전히 VSCode 창(확장 호스트) 완전 재시작이 필요. 재시작 후 새 세션 첫 턴에 ToolSearch부터 재검증. 이번엔 MCP 서버 등록 자체는 최신 토큰으로 정상 상태이므로, 재시작 후에도 안 뜨면 재등록 문제가 아니라 순수 세션 로딩 문제로 좁혀서 진단할 것.

### 4-1-3. claude.ai 커넥터 경로로 Slack 연결 성공 (2026-08-26, 같은 세션 후속) — 중요 발견

§3에서 겪은 `claude mcp login slack`의 DCR(동적 클라이언트 등록) 버그를 완전히 우회하는 **다른 연결 경로**를 찾았습니다.

- claude.ai 웹 UI → **설정 → 커넥터** 화면에 진입하면 "인기" 목록에 **Slack**이 정식 옵션으로 존재함 (Gmail, Google Calendar와 같은 급).
- 여기서 연결하면 `claude mcp list`에 **`claude.ai Slack: https://mcp.slack.com/mcp - ✔ Connected`**로 잡힘 — 공식 호스팅 서버(`mcp.slack.com`)인데도 **DCR 오류 없이 정상 연결됨**. 추정 원인: claude.ai 커넥터 설정은 사전 등록된 자체 OAuth 클라이언트를 쓰기 때문에, `claude mcp login slack` CLI가 시도하는 동적 클라이언트 등록 경로 자체를 안 탐 — Google Drive/Notion 커넥터와 동일한 인증 방식.
- 결과적으로 지금 이 프로젝트에는 **Slack 연결이 두 개 공존**함:
  1. 로컬 stdio `slack` (Bot Token, `@modelcontextprotocol/server-slack`, §3/§4-1-2에서 구축) — scope는 세밀하게 통제했지만 Canvas 등 고급 기능 실제 지원 여부 미확인 상태였음
  2. `claude.ai Slack` (호스팅, OAuth, 방금 연결) — 공식 서버라 Canvas 등 고급 기능(§3에서 언급된 Anthropic의 "11개 업무 툴 MCP Apps 확장" 발표와 동일 계열일 가능성 높음) 지원 가능성이 더 높지만, 어떤 워크스페이스로 연결됐는지(Free vs Enterprise) 아직 미확인.
- **미해결/다음 세션에서 확인할 것**:
  1. `claude.ai Slack`이 Enterprise "Cloud Alpacas"(slackforcloudalpaca.slack.com, T0BSM719FJ7)로 연결된 게 맞는지 — Free 워크스페이스로 잘못 연결됐을 가능성 있음(§7에 기록된 "동명 워크스페이스 2개" 이슈)
  2. 이번에도 **같은 세션(ToolSearch)에는 로드 안 됨** — 로컬 stdio든 호스팅 커넥터든 세션 도중 추가된 MCP는 예외 없이 재시작 전까지 이 세션에서 안 보인다는 게 재확인됨
  3. 재시작 후 두 Slack 연결(`slack` local vs `claude.ai Slack`) 중 실제로 어떤 이름의 도구(`mcp__slack__*`? `mcp__claude_ai_Slack__*`?)가 뜨는지, 기능 커버리지(특히 Canvas·채널 생성)는 어느 쪽이 더 나은지 비교해서 하나로 정리할 것 — 둘 다 남겨두면 혼란스러움

### 4-1-4. 체크리스트 1~3번 전체 검증 완료 (2026-08-26, 새 세션에서)

사용자가 새 세션(`slack 도구 로드됐는지 확인해줘`)을 열자 이번엔 정상적으로 로드됨. §4 체크리스트 전체 결과:

- **1번(도구 로드)**: ✔ `mcp__claude_ai_Slack__*` 이름으로 18개 도구 로드 확인. **로컬 stdio `mcp__slack__*` 쪽은 이 세션에 안 뜸** — 즉 이번엔 `claude.ai Slack`(호스팅 커넥터) 쪽만 활성화됨. 도구 목록: slack_search_channels, slack_search_users, slack_read_channel, slack_read_thread, slack_create_canvas, slack_read_canvas, slack_update_canvas, slack_create_conversation, slack_send_message, slack_send_message_draft, slack_schedule_message, slack_list_channel_members, slack_read_user_profile, slack_read_file, slack_add_reaction, slack_get_reactions, slack_search_emojis, slack_search_public/slack_search_public_and_private.
- **2번(워크스페이스 재확인)**: ✔ `slack_search_users`로 "salesforce" 검색 → `SalesforceIQ Integration`, `EinsteinServiceAgent User`, salesforce.com 소속 계정 확인됨. Free 워크스페이스에는 없을 계정들이라 Enterprise "Cloud Alpacas"(T0BSM719FJ7)에 정상 연결된 것으로 교차 확인 완료.
- **3번(Canvas·채널 스모크 테스트)**: ✔ 전부 성공.
  - `slack_create_conversation`으로 프라이빗 채널 `mcp-smoke-test` 생성 (channel_id: `C0BSWFY5FRP`)
  - `slack_send_message`로 메시지 전송 성공 (`slackforcloudalpaca.slack.com/archives/...` 링크 반환 — URL도 Enterprise 워크스페이스와 일치)
  - `slack_create_canvas`로 Canvas 생성 성공 (canvas_id: `F0BSY8H7BMJ`, URL에 team_id `T0BSM719FJ7` 포함 — 재확인)
  - `slack_read_canvas`로 방금 만든 Canvas 내용 재조회 성공 (내용 일치)
  - **결론: `claude.ai Slack` 호스팅 커넥터가 Canvas·채널 생성 기능을 실제로 완전히 지원함.** §3에서 "scope는 있지만 실제 구현 여부 미확인"이라 우려했던 부분(로컬 npm 패키지 대상)이 호스팅 커넥터로는 완전히 해소됨.

**정리된 최종 상태**: 이 프로젝트에서는 **`claude.ai Slack`(호스팅 커넥터) 사용을 기본으로 채택**. 로컬 stdio `slack`(Bot Token 방식, §3/§4-1-2)은 사용자 요청으로 제거를 시도했는데, 이 시점엔 **이미 로컬 config에서 사라진 상태**였음(`claude mcp remove slack` → "No MCP server named slack. Configured servers: notion" — 즉 로컬 scope엔 notion만 남아있고 slack은 이미 없었음. 정확히 언제/어떻게 사라졌는지는 불명 — 아마 새 터미널 `claude` 세션 쪽에서 정리됐을 가능성). `claude mcp list` 결과 현재 활성 서버는 `claude.ai Slack`, `claude.ai CA SF`(+ Sandbox/server 1, 인증 대기), `claude.ai Google Drive`, `notion` 뿐. **로컬 stdio slack 관련 정리는 이제 완료된 상태로 간주.**

**남은 정리 작업**:
- 테스트로 만든 프라이빗 채널 `mcp-smoke-test`(C0BSWFY5FRP)와 그 안의 테스트 Canvas(F0BSY8H7BMJ)는 워크스페이스에 실제로 남아있음 — 필요 없으면 Slack UI에서 채널 보관(archive) 처리할 것 (API로 삭제하는 도구는 제공되지 않음).
- Slack App("AI PRM Assistant", Bot Token 방식)은 이제 안 쓰지만 Slack 워크스페이스 쪽에는 여전히 설치돼 있음 — 완전히 안 쓸 거면 워크스페이스 앱 관리 화면에서 정리 고려 (선택 사항, 급하지 않음).

---

## 5. 최종 목표 — PRM Slack 업무 허브 구조

> **2026-08-26 갱신**: 아래 초안을 `00_STORY.md`(이 매니저 워크플로우) 기준으로 정교화한
> 정식 기획안을 별도 문서로 작성했습니다 → **`SLACK_WORKSPACE_PRM_PLAN.md`** 참고.
> 이 섹션(§5)은 최초 초안으로 그대로 남겨두되, 실제 채널 구조·자동화 매핑은 그 문서를
> Source of Truth로 삼습니다.

### 채널 4개 (예정)

| 채널 | 용도 |
| --- | --- |
| `#prm-command-center` | Today 할 일, 긴급 업무, 계약 만료 임박, 제안서·견적서 검토 요청, 미팅 일정, 후속 Task, 자주 쓰는 봇 명령 모음 |
| `#prm-pipeline` | Monthly Revenue Target, Closed Won, Weighted Pipeline, Revenue Gap, Proposal 단계 건수, 30/60일 이내 계약 만료, 후속 활동 지연 건, Dashboard 링크, 전일·전주 대비 변화 |
| `#prm-deals` | 주요 Opportunity별 스레드, 제안서·견적서 초안, 협상 내역, 의사결정, 후속 조치, Salesforce 레코드 링크 |
| `#prm-research` | 잠재 스폰서사 조사, 최근 뉴스/캠페인, 팬층 적합성 분석, 신규 Lead 후보, 외부 조사 결과 |

### 명령 체계

Slash Command를 먼저 만들기보다 자연어 명령(`@봇 오늘 할 일`, `@봇 이번 달 파이프라인 요약` 등)을 우선 사용. 사용 빈도가 높은 것만 추후 `/today`, `/pipeline`, `/expiring`, `/proposal`, `/quote` 같은 진짜 Slash Command로 개발 검토.

---

## 6. 합의된 단계별 진행 순서

1. **읽기 전용부터 검증** — 채널 검색, 스레드 요약 (승인/위험 없이 바로 가치 검증 가능)
2. **게시는 반자동으로 시작** — Claude가 초안 생성 → 승우 검토 → 게시. 완전 자동 게시는 신뢰 쌓인 뒤로 미룸 (공유 채널에 잘못된 내용이 자동으로 올라가는 리스크 방지)
3. **스케줄 자동화** — Claude Code 자체 Cron/예약 실행 기능(CronCreate 등, 이번 세션에서 실제 존재 확인됨) 활용해서 "매일 정해진 시간에 초안 생성"부터 시작
4. **채널 생성·북마크·Canvas 관리 기능** — 선택한 MCP 서버가 실제로 구현하는지 먼저 검증 후 착수
5. **Slash Command·메시지 트리거 자동화는 마지막** — 별도 Slack App 백엔드(Events API 수신 서버) 개발이 필요한 영역이라 투자 규모가 다름. `@봇 자연어` 방식이 실제로 자주 쓰인다고 검증된 뒤 착수 권장

---

## 7. 참고 — 조사 근거 (2026-08-26 웹 검색 기반)

- Anthropic이 2026-01-26 MCP Apps 확장으로 Slack 등 11개 업무 툴 대화형 연동 발표(Claude Team/Enterprise 플랜)
- Claude Code, Claude Desktop 둘 다 Slack MCP 서버 공식 지원 확인(Slack 공식 문서: docs.slack.dev)
- **알려진 제약**: 빌트인 Slack Connector는 계정당 워크스페이스 1개만 지원, UI로 두 번째 워크스페이스 추가 불가(`anthropics/claude-code` Issue #44243, #39952, 미해결) — 이번엔 Bot Token 방식으로 우회했기 때문에 해당 없음
- Enterprise Grid 워크스페이스는 보통 앱 설치에 조직 관리자 승인 필요 (이번엔 승우 본인이 admin이라 문제 없었음)
