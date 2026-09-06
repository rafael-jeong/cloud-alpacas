# Seungwoo 개발 기능 총정리 — Cloud Alpacas

> `Individual Development Handoff — Seungwoo — Cloud Alpacas.md`(Git 전수조사 + Salesforce Org 실측 완료본)를 기준으로, 표가 아닌 항목별 서술 방식으로 재구성한 문서다. B2B(가장 중요·특징적인 것 → 덜 중요한 것) 다음 B2C(가장 중요·특징적인 것 → 덜 중요한 것) 순으로 정리했다. 각 항목은 [Feature]/[Business Purpose]/[Salesforce]/[How it works]/[Problem & Solution]/[QA] 6개 필드로 구성했다.
>
> 기준일: 2026-08-31. 2026-08-31 팀 결정으로 해소된 3건(Proposal/Quote Subagent 채택, Named Credential 권한, Campaign_Agent 명칭 충돌)은 전부 반영·완료된 상태로 기술한다.

---

# B2B (스폰서십 영업 — Product / Quote / Campaign)

## 1. [Feature] Sponsorship_Campaign_Agent — 실행 병목 추적 + 갱신 성과 요약 Agentforce Agent

**[Business Purpose]** 스폰서십 계약 체결 후 실행 단계에서, 담당자가 약속한 실행 항목(Deliverable)이 잘 진행되고 있는지 매번 레코드를 열어보지 않아도 파악하고, 병목이 생기면 AI로부터 대책을 추천받아 실제로 도입할 수 있어야 한다. 또한 계약 만료가 다가오면 갱신/업셀 제안에 쓸 이행 결과 요약이 자동으로 나와야 한다.

**[Salesforce]**
- Agent: `Sponsorship_Campaign_Agent`(AgentforceEmployeeAgent, Router-First 구조 — `agent_router` → `bottleneck_monitor`/`renewal_report` 2개 Subagent)
- Apex: `CampaignBottleneckFinder`(조회), `CampaignMitigationRecorder`(쓰기 — Notes 기록+Task 생성), `RenewalSummaryRefresher`(조회 직전 touch-update로 Flow 강제 재계산)
- PermSet: `CA_Campaign_Agent_Access`
- Object/Field: `Campaign_Deliverable__c`(Status__c/Due_Date__c/Blocked_Reason__c/Notes__c), `Campaign`(Performance_Summary__c 등)

**[How it works]** 사용자가 "지연된 항목 있어?"라고 물으면 `bottleneck_monitor`가 `Status__c='Blocked'` 또는 `Due_Date__c<오늘 AND 미완료`인 항목을 전부 조회 → LLM이 대책을 제안 → 사용자가 명확히 승인하면(`require_user_confirmation: True`) `Campaign_Deliverable__c.Notes__c`에 기록 + 후속 Task 생성. "갱신 자료 줘"라고 물으면 `renewal_report`가 대상 갱신 캠페인을 touch-update로 재계산시킨 뒤 최신 `Performance_Summary__c`를 반환.

**[Problem & Solution]**
1. **문제**: 쓰기 액션(`adopt_mitigation`)을 두 번 명확히 요청해도 DB에 아무 변화가 없었다. **원인**: Agentforce Planner가 매 턴마다 Router를 재평가하는데, "판단해서 이동하세요" 수준의 지침으로는 "이전 병목 논의를 이어가는 요청"을 인식 못 해 Router가 스스로 가짜 답변만 하고 실제로는 전환하지 않았다. **해결**: Router 지침을 "직접 답하지 말고 반드시 전환하라"로 명시해 해결 — trace 로그 분석으로 원인을 규명한 사례.
2. **문제**: 갱신 요약의 `completionRate`가 항상 0으로 나옴. **원인**: 갱신 캠페인 자신의 Roll-Up 필드를 읽고 있었는데, 실제 Deliverable은 형제 Collaboration 캠페인이 갖고 있어 갱신 캠페인 자신은 항상 0이었음. **해결**: 그 필드를 아예 제거하고 이미 정확한 `performanceSummary` 텍스트 하나로 통일.

**[QA]** **현재 정상** — Live Preview로 실 데이터 검증: 병목 조회에서 전체 Org 기준 **69건의 "조용한 지연"**(Status는 안 바뀌었지만 기한이 지난 항목) 실제 발견, 갱신 요약 재계산 정확도 확인(55%), 대책 적용→승인→Notes/Task 실제 생성까지 SOQL로 재확인 후 원상복구 완료. **2026-08-31 Publish+Activate 완료, 현재 Active(v1)로 운영 중.** ⚠️ **수정 필요**: Apex 4개 전부 **단위 테스트 커버리지 0%, 테스트 클래스 자체가 없음**(회귀 방지 장치 전무).

---

## 2. [Feature] campaignAgentChat — Campaign 레코드 페이지 임베디드 Agent 채팅 위젯

**[Business Purpose]** 기존 Opportunity Agent처럼, Campaign 레코드 하나를 열었을 때 그 자리에서 바로 Agent에게 질문할 수 있어야 한다는 사용자 요청(이번 세션).

**[Salesforce]**
- LWC: `campaignAgentChat`(컴포저), `campaignAgentChatModal`(대화이력 모달)
- Apex: `CampaignAgentChatController`(Agent API 직접 호출 Transport Bridge)
- FlexiPage: `Campaign_Record_Page3`(Campaign 객체의 org-wide View 페이지로 실제 등록됨)
- Named Credential: `CA_Agent_API_PerUser`(Per-User OAuth, Eunyeong이 만든 것을 재사용)

**[How it works]** 위젯이 첫 턴에 `"(이 대화는 캠페인 '{이름}' 페이지에서 열렸습니다...)"`를 사용자 메시지 앞에 붙여 Agent API 세션을 시작(Record Id가 아니라 **이름으로 컨텍스트 바인딩** — 이 Agent엔 Id 조회 액션이 없어서). 대화 이력은 Salesforce가 아니라 **브라우저 localStorage**에만 저장. 기존 `opportunityAgentChat`(Eunyeong Doh 원작) 패턴을 리버스엔지니어링해서 그대로 클론.

**[Problem & Solution]**
1. **문제**: 위젯 배포 직후 "Named Credential isn't authenticated" 오류. **원인**: Per-User OAuth Principal이 이 사용자에 대해 아직 최초 브라우저 인증을 거치지 않은 상태. **해결**: Setup UI 경로 2가지가 이 화면 버전에서 작동하지 않아, Connect REST API(`POST /named-credentials/credential/auth-url/o-auth`, `principalType: "PerUserPrincipal"`)로 인증 URL을 직접 발급받아 사용자가 브라우저에서 승인.
2. **문제**(2026-08-31 신규 발견): 이 Named Credential의 Per-User Principal 접근 권한이 `CA_Opportunity_Agent_Access`에만 등록되어 있고 `CA_Campaign_Agent_Access`에는 없어서, 이 PermSet만 가진 사용자는 인증에 실패할 구조였다. **해결**: PermSet 메타데이터에 `externalCredentialPrincipalAccesses` 블록을 추가·배포해 등록 완료.

**[QA]** **부분 정상** — 실제 Collaboration Campaign에서 "지연된 항목 있어?" 질문에 정상 응답 확인(권장 테스트 5개 중 1개 완료). ⚠️ **수정 필요**: 전체 스캔/다른 캠페인 명시 전환/대책 적용+승인/대화이력 열람+삭제 4개 시나리오는 브라우저에서 아직 미검증(백엔드 Agent 자체는 CLI로 이미 검증됨).

---

## 3. [Feature] Campaign 화면 구조 재설계 — Record Type별 Page Layout 분리

**[Business Purpose]** Sponsorship_Prospecting/Collaboration/Renewal 3개 생애주기 단계가 화면 구성 없이 Layout 1개를 공유해, 각 단계에서 실제로 필요 없는 필드(Renewal 화면의 실행 가중치, Collaboration 화면의 항상 빈 성과 요약 등)까지 노출되어 "정보가 뒤섞여 보인다"는 사용자 지적을 받았다.

**[Salesforce]**
- Layout(신규 2개): `Sponsorship Collaboration Execution Layout`, `Sponsorship Renewal Layout`
- ProfileLayout 배정 변경(System Administrator Profile, Collaboration/Renewal 2종만 — Prospecting은 범위 밖이라 기존 유지)

**[How it works]** Collaboration 레이아웃은 "기본정보→실행현황(가중치+기간)→재무→설명" 순으로, Renewal 레이아웃은 "기본정보→갱신성과(성과요약 최상단)→재무/기간→설명" 순으로 재배치. Related List도 Collaboration은 Campaign Deliverables를 최상단으로, Renewal은 Deliverables/Members를 아예 빼고 Opportunities만 남김.

**[Problem & Solution]**
1. **문제**: Page Layout Assignment 화면에 이름이 완전히 같은 "System Administrator" 행이 2개 있어, 잘못된 프로파일에 변경을 적용할 뻔했다. **해결**: Tooling API로 실제 사용자의 정확한 ProfileId를 먼저 조회해 대조, 그 값과 일치하는 행만 골라 변경.
2. **문제**: 로컬에 있던 Layout 파일들이 실제 Org 상태와 전혀 다른(구버전) 내용이었다. **해결**: 편집 전 항상 `sf project retrieve`로 최신 상태를 다시 받아온 뒤 작업.

**[QA]** **현재 정상** — 사용자가 실제 Collaboration/Renewal 레코드 화면을 각각 열어 스크린샷으로 의도한 섹션 순서·필드 노출·Related List 우선순위가 정확히 반영됨을 확인.

---

## 4. [Feature] Campaign_Deliverable__c — 스폰서십 실행 과업 추적 (신규 Custom Object)

**[Business Purpose]** 표준 Campaign에는 "이번 협업에서 하기로 한 개별 실행 항목"(전광판 시안 승인, LED 설치, Brand Day 부스 준비 등)을 담을 필드가 없어, 실행 진행률을 추적할 수 없었다. 위 1·2·3번 기능 전부 이 Object 위에서 돌아간다.

**[Salesforce]**
- Object: `Campaign_Deliverable__c`(Master-Detail → Campaign, AutoNumber `DLV-{0000}`)
- Field: `Status__c`, `Weight__c`(진짜 필수, 기본값 없음), `Due_Date__c`, `Notes__c`, `Blocked_Reason__c`, `Completed_Date__c`, `Evidence_URL__c`, `Due_Date_Pushed__c`, `Pending_Slack_Message__c`

**[How it works]** Collaboration Campaign 생성 시 4건 템플릿(계약서 서명 20 → 브랜드 노출물 제작 착수 20 → 설치·게시 30 → 성과 리포트 30, 가중치 합 100)을 적용. 이 Weight__c 합산이 Campaign의 Roll-Up 필드(전체/완료 이행 항목 가중치)로 올라가고, 그게 Renewal 성과 요약과 Agent 병목 조회의 기초 데이터가 된다.

**[Problem & Solution]**
1. **문제**: 필드 4개가 배포 후 5일간 SOQL/describe에서 조회 불가. **원인**: 이 Org 고유의 스키마 전파 지연 버그(이 세션에서 최소 7개 필드에서 재현). **해결**(1차): 필드 삭제 후 동일 스펙으로 재생성. 이후 다른 필드(Performance_Summary__c)에서 이 방법이 24시간 넘게 안 통하는 재발 사례를 겪은 뒤 근본 원인을 재규명 — **Metadata API 배포 자체가 막혀있고, Setup UI "New Custom Field" 마법사는 완전히 다른(정상 동작하는) 내부 경로를 탄다**는 것을 발견해 그 방법으로 전환.

**[QA]** **현재 정상** — d'Alba 2년차 기준 실 데이터로 Roll-Up 계산 정확히 일치 확인, 전체 Collaboration 캠페인(5개 헤어 스폰서 + Aaron 데이터 연동 75개)에 316건 실데이터 채움 완료.

---

## 5. [Feature] Renewal_Campaign_Performance_Summary — 갱신 성과 자동 요약 Flow

**[Business Purpose]** 갱신 제안 시 스폰서사에게 제시할 성과 리포트를 자동 생성해야 한다. 초기엔 매출/순이익을 넣으려 했으나 "이건 구단 입장의 이득이지 스폰서사에게 제시할 근거가 아니다"라는 피드백으로, 티어별(Gold=노출 수/Platinum=도달+반응+반응율/Diamond=독점 도달+계약 성장률) 성과지표로 전면 재설계했다.

**[Salesforce]**
- Flow: `Renewal_Campaign_Performance_Summary`(Record-Triggered, Before-Save)
- Field(Campaign): `Performance_Summary__c`, `Total_Deliverable_Weight__c`/`Completed_Deliverable_Weight__c`(Roll-Up Summary)

**[How it works]** 갱신 캠페인이 저장될 때마다, Campaign Hierarchy로 연결된 형제 Collaboration 캠페인들의 팬 도달/반응/Deliverable 이행률/계약 성장률을 집계 → 연결된 Opportunity의 `Partner_Tier__c`로 티어를 판별 → 3가지 요약문 중 하나를 자동으로 채운다.

**[Problem & Solution]**
1. **문제**: `Get_Collab_Campaigns` 조회의 filter 하나가 `null__NotFound`라는 깨진 필드 참조로 저장돼 있어, Active여도 실행할 때마다 오류가 나게 되어 있었다. **해결**: 실제 `RecordTypeId` 값 비교로 교체.
2. **문제**(2026-08-31, 발표 리허설 중 발견): 이 Flow는 갱신 캠페인 **자신이 저장될 때만** 재계산돼, 형제 Deliverable이 바뀌어도 반영이 안 된다. **해결**: 정식 수정(Flow 추가)은 보류했지만, **같은 날 Sponsorship_Campaign_Agent의 `get_renewal_summary`가 조회 직전 touch-update로 강제 재계산**시키는 방식으로 실질적으로 우회 해결됨.

**[QA]** **현재 정상(알려진 한계 있음)** — d'Alba 2027 시즌 갱신 캠페인에 실제 2회 저장 테스트 전부 성공, 이행률 40%가 실 Deliverable 데이터(총 200/완료 80)와 정확히 일치. ⚠️ Flow 자체의 "형제 캠페인 변경 자동 미반영" 정식 수정은 여전히 미착수(Agent 경유 조회로는 완화됨).

---

## 6. [Feature] Campaign 실행 지연 → Slack 실시간 알림

**[Business Purpose]** 지연 사유가 쌓여도 담당자가 레코드를 일일이 열어보지 않으면 알 수 없었다 — "지연이 생기면 실시간으로 알림받자"는 팀 피드백에서 시작.

**[Salesforce]**
- Flow: `Campaign_Deliverable_Detect_Due_Date_Push`(Before-Save, 메시지 조립), `Campaign_Deliverable_Blocked_Slack_Alert`(After-Save 비동기, 발송)
- Field: `Pending_Slack_Message__c`, `Due_Date_Pushed__c`(현재 미사용), `Blocked_Reason__c`
- 외부: Slack 코어 액션(`SendMessageToSlackChannel`), `#campaign-alerts` 채널

**[How it works]** Status→Blocked 전환 또는 Due Date 연기를 Before-Save가 감지해 메시지를 필드에 조립 → After-Save가 그 필드가 채워지면 Slack 발송 후 다시 비움(다음 지연 재감지 가능하도록).

**[Problem & Solution]** **문제**: 비동기 경로의 `{!$Record.필드}`는 저장 순간이 아니라 "비동기 작업이 실제 실행되는 시점의 최신값"을 다시 읽어, 연속 수정 시 이미 stale해진 사유가 빈 값으로 발송되는 버그가 실제로 발생했다. **원인**: `$Record__Prior`(이전 값 비교)는 동기(Before-Save)에서만 유효하고, 비동기 경로는 매번 최신 레코드를 재조회하기 때문. **해결**: 저장 시점에 필요한 값을 Before-Save에서 미리 텍스트로 조립해 별도 필드에 저장하고, 비동기 Flow는 그 필드를 그대로 읽기만 하도록 구조를 분리.

**[QA]** **현재 정상** — `Blocked_Reason__c` 6개 값 + 메모 없음 폴백까지 총 7개 케이스 전부 실 데이터로 순차 발송·확인, 특수문자 포함 한글 텍스트 깨짐 없음. ⚠️ `Due_Date_Pushed__c` 필드는 리팩터링 후 미사용 상태로 남아 정리 필요.

---

## 7. [Feature] Sponsorship_Proposal_Assistant — Opportunity Agent "Proposal/Quote" Subagent (Superseded)

**[Business Purpose]** 영업 담당자가 Opportunity의 Proposal 단계에서 적합한 Sponsorship Package 추천을 받고, 초안을 만들고, 확인 후에만 실제 Quote로 저장하도록 돕는다 — 팀이 승인한 "메인 Opportunity Agent + Subagent 5개" 구조 중 승우가 맡은 조각.

**[Salesforce]**
- Agent: `Sponsorship_Proposal_Assistant`(단일 `start_agent`, Router 없음 — 메인 Agent에 편입될 것을 전제로 설계)
- Apex(3개, 승우가 설계·구현·Live Preview까지 완료): `OpportunityProposalContext`, `SponsorshipPackageLookup`, `SponsorshipProposalSaver`

**[How it works]** Opportunity 언급 → Lead/Opportunity B2B 필드 조회 → 활성 Sponsorship Package 목록 조회 → LLM이 추천 → 사용자가 "저장해줘"로 명시 확인 → Quote/QuoteLineItem 생성 + Opportunity 3개 Benefit 필드 갱신.

**[Problem & Solution]**
1. **문제**: 초안(Candidate Set을 강제하는 7-Action 구조)이 팀이 독자적으로 준비 중이던 더 넓은 5-Subagent 구조와 중복됐다. **해결**: Candidate Set 강제를 버리고 LLM이 실제 조회 결과에 근거해 직접 추천하는 3-Action 단순 구조로 전면 재설계.
2. **문제**(2026-08-31 발견): 이 산출물(PermSet+Apex 3개)이 실제로는 `origin/main`에 merge된 적이 없고, 같은 이름의 컴포넌트를 Opportunity Agent 통합 담당자(Eunyeong Doh)가 독립적으로 다시 만들어 그 버전이 실제 운영되고 있었다. **해결(2026-08-31 팀 결정)**: 승우가 검토 후 **"Eunyeong의 구현이 맞다"고 확인 — Eunyeong 버전을 공식 채택**, 승우 버전은 Superseded 처리하고 관련 문서에 표기 완료.

**[QA]** **Superseded — 승우 버전은 더 이상 사용 안 함.** 검증 자체는 실제로 통과했었다(Live Preview로 실 Quote·QuoteLineItem·Opportunity 필드 생성까지 SOQL 재확인 완료) — 설계·구현 역량은 실증됐으나 최종 채택된 코드는 아니다.

---

## 8. [Feature] Campaign.ExpectedRevenue ↔ Opportunity.Amount 자동 동기화

**[Business Purpose]** `Campaign.ExpectedRevenue`가 손으로 복사한 값이라 Opportunity.Amount가 바뀌어도 따라가지 않는 데이터 정합성 위험이 있었다.

**[Salesforce]** Flow 3개(Subflow 패턴): `Recalculate_Campaign_Expected_Revenue`(계산 로직), `Campaign_Expected_Revenue_Sync`(생성/수정), `Campaign_Expected_Revenue_Sync_On_Delete`(삭제)

**[How it works]** Opportunity 생성/수정/삭제(CampaignId 있는 경우) → Subflow가 해당 Campaign에 연결된 전체 Opportunity Amount를 재합산 → `Campaign.ExpectedRevenue` 갱신.

**[Problem & Solution]** **문제**: Opportunity→Campaign이 Lookup 관계라 Roll-Up Summary를 못 쓰고, Record-Triggered Flow는 생성/수정과 삭제를 한 Flow에서 동시에 못 다룬다. **해결**: Flow 2개로 분리하되 "제외할 Opportunity Id가 비어있으면 아무것도 제외 안 됨" 성질을 이용해 로직 중복 없이 Subflow 하나로 통일.

**[QA]** **현재 정상** — 실 데이터 테스트 PASS(생성 시 자동 반영, 삭제 시 자동 복구). ⚠️ Opportunity의 Campaign이 A→B로 재연결되는 경우 예전 Campaign(A)의 합계는 갱신 안 되는 한계가 남아있음(미착수).

---

## 9. [Feature] Campaign Record Type 확장 및 Hierarchy — 스폰서 생애주기 관리

**[Business Purpose]** 계약 체결 전(잠재 스폰서사 발굴)과 계약 만료 임박(갱신 제안) 단계를 Campaign으로 관리할 필요가 있었는데, 기존엔 Fan_Campaign/Sponsorship_Collaboration 2종뿐이었다.

**[Salesforce]** Record Type 신규 2종(`Sponsorship_Prospecting`, `Sponsorship_Renewal`), Campaign Member Status 5단계 퍼널(Targeted→Reached→Engaged→Attended→Converted), Campaign Hierarchy(Parent Campaign) 5개 스폰서 확장, List View 4종, Path Assistant 3종

**[How it works]** Campaign 생성 시 Record Type으로 발굴→실행→갱신 단계를 구분 → 각 단계 전용 Path/List View로 진행 상황 추적 → Hierarchy로 스폰서 단위 합산(`HierarchyExpectedRevenue` 등 표준 Rollup).

**[Problem & Solution]** **문제**: Metadata API로 RecordType은 배포됐지만 Profile의 RecordType 가시성·Layout 배정은 자동 반영이 안 됐다. **해결**: Setup UI(Object Settings)에서 수동 Enable + Layout 배정, describe API로 재확인.

**[QA]** **현재 정상** — d'Alba/그린빈/루나 등 실제 5개 스폰서 기준 Hierarchy Rollup API 검증 PASS. Decision 023으로 4종 RecordType 동결(추가 확장 안 함) 확정.

---

## 10. [Feature] B2B Sponsorship Report 5종 + Dashboard 7위젯

**[Business Purpose]** Fan Insight처럼 B2B Sponsorship Pipeline/ROI도 Object 신설 없이 Report/Dashboard로 가시화해야 했다(Decision 018-J 원칙의 연장).

**[Salesforce]** Report 5종(Collaboration ROI+Net Profit 수식, Pipeline by Stage, Open Package Count, Average Quote Amount, Collaboration Status), 기존 2개(Deliverable Status, Member Funnel)와 합쳐 Dashboard `PRM Sponsorship Campaign Performance` 총 7위젯

**[How it works]** Net Profit은 Custom Summary Formula(`EXP_REVENUE:SUM - ACTUAL_COST:SUM`)로 Parent Campaign(스폰서)별 순이익을 원 단위로 바로 확인 가능.

**[Problem & Solution]** **문제**: 그룹핑이 없는 Report를 Dashboard 위젯(Metric)에 추가하면 "We can't get data for this widget right now" 오류. **원인**: Salesforce가 그룹 없는 Summary Report를 내부적으로 Tabular로 되돌리는데, Metric 위젯은 Tabular를 지원 안 함. **해결**: 의미 있는 그룹(Stage)을 하나 추가해 진짜 Summary 형식으로 고정.

**[QA]** **현재 정상** — 전체 합계 기준 순이익(예상매출 33억-실집행비용 6천만=32.4억) API 재조회로 검증.

---

## 11. [Feature] Product2 — Sponsorship Package (21종, 3차 가격 조정)

**[Business Purpose]** 스폰서십 상품(구장 광고, Brand Day, 지위 인증권 등)을 팔 수 있는 단위로 표현해 Opportunity/Quote에 실어야 한다. Product/Quote/Campaign 3파트 중 가장 먼저(2026-08-20) 구축된, 승우 담당 영역의 출발점.

**[Salesforce]** `Sponsorship_Package` Product2 Record Type(표준 기능만, 신규 Apex/LWC 0건), PricebookEntry 21건, Revenue Schedule(기간 분할 매출 인식) 활성화

**[How it works]** Opportunity에서 이 RecordType의 Product2를 OpportunityLineItem으로 추가 → Standard Price Book 가격 적용. 전광판 광고처럼 기간에 걸친 상품은 Revenue Schedule로 월별 분할.

**[Problem & Solution]** **문제**: 최초 가격표가 상대적 순위 오류(명명권<유니폼 패치)와 낮은 절대가로 시장성 부족. **해결**: 실제 KBO/MLB 시세 벤치마크 조사 후 3차에 걸쳐 재조정(순위 교정→구단 성장 스토리 반영 1.5배→계열사 벤치마크 대비 하향 보정한 1.3배 추가) — 최종 0.6억~52.2억, 팀 승인 완료.

**[QA]** **현재 정상** — d'Alba 테스트 상품으로 Opportunity Product 연결까지 E2E PASS(2026-08-20). 21종 확장분은 가격표만 갱신, 구조 재검증은 최초 1건 기준.

---

## 12. [Feature] Standard Quote — 스폰서십 견적서

**[Business Purpose]** 스폰서십 제안 금액을 공식 견적서로 관리하고 PDF로 외부 전달할 수 있어야 한다.

**[Salesforce]** Standard Quote/QuoteLineItem(Custom Object 아님, Decision 018-C), Quote Template(`Cloud Alpacas Sponsorship Quote`), Quote Sync 연동

**[How it works]** Opportunity → Create Quote → Quote Line Item 자동 채움 → Start Sync → PDF 생성.

**[Problem & Solution]** **문제**: Quote Sync 중 Opportunity Line Item을 직접 고치면 값이 에러 없이 조용히 원복됨. **원인**: Sync 엔진이 QuoteLineItem을 기준(source)으로 취급. **해결**: 팀 공유 — Syncing 중에는 Quote Line Item 쪽만 수정.

**[QA]** **현재 정상** — 2026-08-20 E2E 검증(생성/Sync/PDF/List View) PASS. ⚠️ Postal Code 등 Company Information 일부 미입력, Quote `Rejected`/`Denied` 실사용 구분 팀 미합의.

---

## 13. [Feature] PricebookEntry 협상 하한선 필드 + Product2 Description 보강

**[Business Purpose]** Opportunity Negotiation 단계에서 담당자가 가격을 어디까지 인하해도 되는지 회사 기준이 없었다. 또한 Agentforce로 견적 생성 시 상품 상세 설명이 축적되어 있지 않아 활용 못 하는 문제도 함께 발견.

**[Salesforce]** `PricebookEntry.Max_Discounted_Price__c`/`Max_Discount_Percent__c`(신규), `Product2.Description` 13개 상품 실사용 수준으로 재작성

**[How it works]** 13개 Sponsorship Package 전부에 희소성 기준 할인 정책(프리미엄 자산일수록 할인 폭 좁게 — 명명권 5%, 앱 배너 20% 등) 반영.

**[Problem & Solution]** **문제**: 이 필드 신설 과정에서 Campaign_Deliverable__c와 동일한 스키마 전파 지연 버그를 재현. **해결**: Setup UI 수동 생성이 API 배포보다 안정적이라는 근본 해결책을 여기서 처음 발견 — 이후 Campaign의 4개 필드에도 동일하게 적용.

**[QA]** **현재 정상** — 필드 생성 직후 Apex로 실제 값 저장/조회 확인 완료.

---

## 14. [Feature] Opportunity.CampaignId 대량 연결 — 104개 회사 Campaign 신규 생성 (파트 경계 보고 사례)

**[Business Purpose]** Aaron Choi가 별도로 만든 대규모 B2B Opportunity 104건에 연결할 Campaign 자체가 하나도 없어, Campaign Hierarchy Rollup의 실사용 공백을 해소해야 했다.

**[Salesforce]** Campaign 104개 신규 생성(Opportunity Stage 기준 RecordType 매핑: Closed Won→Collaboration 75건, 진행중/Closed Lost→Prospecting 29건), Campaign_Deliverable__c 300건 신규(Collaboration 75개 × 4건 템플릿), `Opportunity.CampaignId` 104건 연결

**[How it works]** 회사(Account)당 1개씩 Campaign을 자동 생성하고 기존 5개 헤어 스폰서와 동일한 템플릿 구조를 일괄 적용 — 개별 서사보다 구조·데이터 완결성 위주.

**[Problem & Solution]** **문제**: 이건 다른 팀원(Aaron Choi)이 만든 Opportunity 데이터를 건드리는 파트 경계 작업이었다. **해결**: 승우 자신이 선언한 원칙("파트 내 고도화는 즉시 실행, 파트 경계를 넘는 경우 사후 보고")에 따라 Opportunity 레코드 자체나 기존 필드값은 건드리지 않고 `CampaignId`(빈 필드)만 채우고, 신규 생성물은 전부 Campaign 파트 소유 오브젝트로 한정.

**[QA]** **현재 정상, 단 공유 필요** — 전체 Opportunity 110건 중 테스트 데이터 3건 제외 107건 전부 연결 완료. ⚠️ Aaron Choi에게 이 사실이 아직 전달되지 않음(미전달).

---

## 15. [Feature] Campaign 부가 정비 — 재무 필드 노출/한글 Help Text/Company Information

**[Business Purpose]** Salesforce 표준 Campaign ROI 계산을 스폰서십에도 활용하고, 필드 의미를 팀원 모두가 헷갈리지 않게 하고, Quote PDF 발신 정보를 실사용 가능하게 만들어야 했다.

**[Salesforce]** Campaign `Sponsorship Financials` 섹션(BudgetedCost/ActualCost/ExpectedRevenue), Product2/Quote/Campaign/Campaign_Deliverable__c 총 16개 필드 한글 Help Text, Organization Company Information(주소/연락처)

**[How it works]** ExpectedRevenue는 실제 값(8번 Flow가 자동 반영), BudgetedCost/ActualCost는 승우가 만든 시나리오 값(Deliverable 진행률 비례 산정, 실제 재무 데이터 아님 — 명시적으로 문서화됨).

**[Problem & Solution]** **문제**: 표준 필드(BudgetedCost 등) 자체의 Label을 바꾸려 하면 `Cannot specify label on standard field`로 배포 실패. **해결**: Label 대신 `inlineHelpText`는 배포 가능함을 확인해 그쪽으로 대체.

**[QA]** **현재 정상, 일부 자리표시자** — ⚠️ BudgetedCost/ActualCost는 실제 재무 데이터로 교체 필요, Postal Code 등 Company Information 일부 미입력.

---

# B2C (Fan Relationship Management — Phase 1 Fan 360 MVP)

> Phase 1(2026-08-14 완료)은 이번 세션의 조사 범위 밖이라 Git에는 흔적이 없다(승우의 git 첫 커밋 자체가 08-20, Phase 1은 그보다 이전). 아래는 전부 **Salesforce Org의 CreatedBy/LastModifiedBy를 직접 재조회**해서 확인한 내용이다 — `docs/members/01_SEUNGWOO.md`의 담당 오브젝트 목록은 문서 자체가 "제안 상태(제안이지 확정 아님)"라고 명시하고 있어서, 실제로 무엇을 만들었는지는 이 재조회로만 확정했다.

## 16. [Feature] Fan 360 핵심 데이터 모델 — Custom Object 9종 설계·구축

**[Business Purpose]** "신규 팬을 이해하고 적절한 시점에 개인화된 액션으로 충성 팬으로 성장시킨다"는 Business Goal을 구현하려면, 팬의 관람 이력·관심 신호·세그먼트 변화·추천 이력을 각각 저장할 데이터 구조가 필요했다. 표준 Salesforce Object로는 이 중 어느 것도 표현할 수 없어 전부 새로 설계했다.

**[Salesforce]** `Game__c`(경기, `Season__c`의 Master-Detail 자식), `Admission__c`(개별 입장, `Attendance_Record__c`의 Master-Detail 자식 — "몇 번" 왔는지와 "언제" 왔는지를 분리), `Attendance_Record__c`(누적 관람 집계, 자동화 트리거 기준), `Engagement_Signal__c`(구매 전 관심 신호), `Fan_Activity_Pattern__c`(VIP 후보 감지 Flow의 트리거 근거), `Fan_Segment_History__c`(세그먼트 변화 이력), `Notification_Log__c`(발송 이력, Fan Timeline 핵심 데이터), `Benefits__c`(Recommendation의 결과물인 혜택), `Recommendations__c`(Next Best Action 산출물)

**[How it works]** 팬의 실제 행동(입장, 구매, 관심 신호)이 쌓이면 `Attendance_Record__c`/`Fan_Activity_Pattern__c`가 이를 집계해 자동화(아래 17번 Flow)의 트리거 조건이 되고, 그 결과로 `Recommendations__c`/`Benefits__c`/`Notification_Log__c`가 생성되어 Fan Timeline에 쌓인다.

**[Problem & Solution]** **문제**: `03_SYSTEM.md` 설계 문서 자체가 `Benefit__c`/`Recommendation__c`(단수형)를 공식 API 이름으로 표기하고 있는데, 실제 Org에는 **`Benefits__c`/`Recommendations__c`(복수형)로 배포**되어 있어 문서와 실제 API 이름이 다르다(describe 실패 + Tooling API 조회 두 가지 방법으로 교차 확인). 기능 자체는 정상 존재하며 이름 표기만 다르다 — 앞으로 이 두 Object를 다룰 때는 반드시 복수형을 써야 한다.

**[QA]** **현재 정상** — 9개 Object 중 7개(`Game__c`/`Admission__c`/`Notification_Log__c`/`Engagement_Signal__c`/`Attendance_Record__c`/`Fan_Segment_History__c`/`Fan_Activity_Pattern__c`)는 필드 레벨까지 100% 승우 단독 저작으로 확인. 나머지 2개(`Benefits__c`/`Recommendations__c`)는 핵심 필드는 승우 저작, 이후 Phase 2에서 Sara Bang이 필드 3개씩 추가(정상적인 확장, 충돌 아님).

---

## 17. [Feature] Fan Lifecycle 자동화 Flow 6종 — Welcome/VIP 후보 감지/첫 티켓·관람·굿즈·최애선수 캠페인

**[Business Purpose]** 김매니저가 신규 팬 이루키를 충성 팬으로 성장시키는 8/14 Phase 1 데모의 실제 동작 흐름 — Business Goal("적절한 시점에 개인화된 액션")을 실제로 자동 실행하는 부분.

**[Salesforce]** `Welcome_Campaign_Flow`(신규 Person Account 생성 트리거), `First_Ticket_Campaign_Flow_V1`(가입 7일 후 미구매 감지), `First_Visit_Guide_Flow`(첫 관람 감지 — `Attendance_Record__c` 롤업이 1이 되는 순간), `First_Merchandise_Campaign_Flow_V1`(관람은 했지만 굿즈 미구매), `Favorite_Player_Campaign_Flow_V1`(첫 굿즈 구매 완료), `VIP_Candidate_Detection_Flow_V1`(반복 관람 3회+ AND 지출 임계값 충족 시 감지)

**[How it works]** 각 Flow가 팬의 행동 변화(가입/미구매/첫관람/미구매/구매완료/반복방문)를 트리거로 삼아 `Fan_Segment_History__c` 갱신, `Notification_Log__c`/`Recommendations__c` 생성, VIP 후보는 자동으로 등급을 올리지 않고 **Slack으로 매니저에게 알려 사람이 확인하게** 설계됨.

**[Problem & Solution]** **문제(이 문서 작성 중 발견, 정확히 반영 필요)**: 승우는 6개 Flow의 **V1을 전부 2026-08-13 23:41~23:44(3분 안)에 몰아서 만들었지만**, 지금 실제로 운영되고 있는 버전은 **6개 전부 Sara Bang이 Phase 2 기간(08-24~08-27)에 새 버전으로 교체한 것**이다(`VIP_Candidate_Detection_Flow_V1`은 5차례 더 개정됨). 승우의 원본 버전은 현재 하나도 활성 상태가 아니다. 이건 B2B의 Proposal/Quote Subagent와 같은 패턴(원 저작자의 버전이 팀원의 후속 작업으로 대체됨)이며, 실제 로직이 얼마나 달라졌는지(문구 수정 수준인지 구조 변경인지)는 이번 조사에서 XML까지 대조하지 않아 확인하지 못했다.

**[QA]** **현재 정상 운영 중 — 단, 지금 도는 코드는 승우 것이 아니라 Sara Bang의 개정판.** 원본 설계(트리거 조건, 어떤 Object에 무엇을 남길지)는 승우 안이 그대로 이어지고 있는 것으로 보이나(트리거 대상 Object·자동화 방향 자체는 바뀌지 않음), 정확한 차이는 팀 확인 필요.

---

## 18. [Feature] Person Account 기반 Fan/Player 데이터 확장

**[Business Purpose]** 표준 Account/Contact만으로는 "팬"과 "선수"라는 이 프로젝트 고유의 개념(마케팅 동의, 세그먼트, 최애 선수, 등번호 등)을 표현할 수 없었다.

**[Salesforce]** Account Record Type `Fan`(+12개 필드: `Acquisition_Channel__c`, `Current_Segment__c`, `Segment_Updated_Date__c`, `SMS_Opt_In__c`/`Push_Opt_In__c`/`Kakao_Opt_In__c`/`Email_Opt_In__c`, `Consent_Updated_Date__c`, `Fan_Value_Tier__c`, `Engagement_Level__c`, `Engagement_Score__c`, `Favorite_Player__c`), Contact Record Type `Player`(+`Position__c`, `Uniform_Number__c`)

**[How it works]** Person Account 자체(표준 인프라, Org 세팅 첫날 자동 프로비저닝됨)를 기반으로, 승우가 그 위에 Fan Record Type과 마케팅 동의·세그먼트·참여도 필드를 올렸다. 이 필드들이 위 16·17번 Object/Flow가 실제로 읽고 쓰는 대상이다.

**[Problem & Solution]** **문제**: `03_SYSTEM.md`가 스스로 "Org 존재 여부 미확인"으로 플래그해둔 항목(`Account.Gender__c` 등)이 실제로 있는지 애매했다. **확인 결과**: `Gender__c`라는 이름의 필드는 실제로 없고, 대신 `Report_Gender__c`라는 다른 이름의 필드가 있으며 이건 승우가 아니라 Sara Bang이 나중에(08-27) 만든 것 — 문서의 "미확인" 표시가 정확히 들어맞은 사례.

**[QA]** **현재 정상** — 12개 필드 전부 승우가 만들고 승우가 마지막으로 수정(같은 날, 2026-08-11).

---

## 19. [Feature] Order/OrderItem/Product2 — 티켓·멤버십·굿즈 판매 데이터 구조

**[Business Purpose]** 팬의 구매 행동(티켓/멤버십/굿즈) 자체를 표준 Order/OrderItem으로 표현하되, 좌석·시즌권 기간·환불 등 야구단 특유의 정보를 담을 필드가 필요했다.

**[Salesforce]** Order: `Order_Type__c`, `Purchase_Channel__c`, `Game__c`, `Membership_Status__c`, `Coverage_Start_Date__c`/`Coverage_End_Date__c`, `Payment_Status__c`, `Refund_Date__c`/`Refund_Reason__c`. OrderItem: `Section__c`, `Row__c`, `Seat_Number__c`, `Current_Owner__c`, `Transfer_Status__c`. Product2: `Tier__c`, `Category__c`, `Related_Player__c`.

**[How it works]** Ticket/Membership/Goods/Season Pass를 Product2 RecordType으로 구분하고, 실제 판매는 Order/OrderItem에 좌석 정보와 시즌권 유효기간까지 담아 기록한다.

**[Problem & Solution]** **문제**: `03_SYSTEM.md`가 "TBD/미확인"으로 남겨둔 `Order.Payment_Method__c`, `OrderItem.Size__c`(굿즈 사이즈)가 실제로 만들어졌는지 불명확했다. **확인 결과**: 둘 다 실제로 존재하지 않는다 — 설계 문서에 아이디어로만 남고 실제 구현까지 가지 않은 항목으로 확정.

**[QA]** **현재 정상** — 승우가 문서화한 필드 목록과 실제 Org 필드가 정확히 1:1로 일치(더 많지도 적지도 않음), 전부 승우 단독 저작.

---

## 20. [Feature] Case.Related_Order__c — 문의-주문 연결

**[Business Purpose]** 팬이 특정 주문 건에 대해 문의(환불, 배송 등)할 때 그 Case가 어느 Order에 대한 것인지 연결해야 한다.

**[Salesforce]** `Case.Related_Order__c`(Lookup to Order) — Case 객체의 기존 59개 커스텀 필드는 전부 Org 세팅 당일(08-10) 배포된 Field Service/OMS 데모 baseline이고, 승우가 실제로 손댄 건 이 필드 하나뿐이다.

**[How it works]** Case 생성 시 관련 Order를 지정하면, 상담원이 어느 구매 건에 대한 문의인지 바로 확인 가능.

**[Problem & Solution]** 특별한 이슈 없이 단순 추가.

**[QA]** **현재 정상** — 승우 단독 저작, 변경 이력 없음.

---

