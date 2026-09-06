## ✅ 2026-09-01 실행 결과 — P0-1, P1-3~5, P2-6~8 완료 (P0-2 가격 결정은 대기 중)

아래 §4 우선순위 중 **P0-2(가격 기준값)와 §5의 Diamond/Platinum 설계 결정을 제외한 전부**를 실제 Org에 반영했습니다.

| 항목 | 실행 내용 |
|---|---|
| P0-1 | `2026 시즌 스폰서 Thank You Day` Campaign 신규 생성(Id `701bm00002m7rb0AAA`, Sponsorship_Collaboration, 2026-11-14, Active) + Contact 김하나를 CampaignMember(Status=Responded)로 연결 |
| P1-3 | Gold Opp의 무내용 "협상 후속 연락" Task 16건 전량 삭제 |
| P1-5 | Gold Opp에 Task 3건(초기 니즈 파악 콜/조건 협의 콜/단가 확인) + Email 2건, Diamond·Platinum Opp에 Email 1건 신규 작성. 기존 Event 3건에 실제 설명 보강, "Platinum Sponsorship Discussion" → "차기 시즌 Platinum 확장 가능성 사전 논의"로 한글화 |
| P1-4 | Gold/Platinum 협업 캠페인에 실제 Fan Contact 6명(이루키 포함) 추가, 그중 4명은 응답(Engaged/Attended/Converted) 처리 |
| P2-6 | 중복 Lead(`00Qbm00000oJRpJEAW`) + 고아 테스트 Lead(`00Qbm00000oZViTEAW`) 삭제 |
| P2-7 | Gold/Platinum 협업 캠페인 StartDate/EndDate를 Deliverable 마감일 범위에 맞게 재조정, d'Alba 관련 Campaign 5건 전부 IsActive=true로 전환 |

**⚠️ 실행 중 예상 못한 부작용 발견**: 위 작업 후 Renewal 캠페인의 `Performance_Summary__c`가 자동 재계산되면서 문구 자체가 바뀌었습니다.

- 이전: "**Platinum** 파트너 갱신 참고자료 ... **Diamond 승급**을 제안드립니다" (반응율 0% 명시)
- 이후: "**Gold** 파트너 갱신 참고자료 ... **Platinum 승급**을 제안드립니다" (반응율 문장 자체가 사라지고 노출 팬 수만 8명으로 표시)

원인으로 추정되는 것: 이 Flow는 (Slack 보고서 Apex와 유사하게) "가장 최근 수정된 연결 Opportunity"의 Partner_Tier__c를 기준으로 문구를 만드는 것으로 보이는데, 이번 정제 작업에서 Gold Opp의 Activity를 Diamond/Platinum Opp보다 나중에 건드리면서 기준이 Gold Opp으로 바뀐 것으로 보입니다. Flow 로직을 직접 열어보지 않아 100% 확정은 아니며, 이 결과가 "틀린 것"이라기보다 — 실제로 org에 이미 Platinum 티어 Campaign/Opportunity가 존재하니 "Gold→Platinum 제안"이 오히려 더 일관성 있어 보이기도 합니다. 다만 **발표에서 읽을 문구가 Opportunity를 누가 언제 마지막으로 건드렸는지에 따라 바뀔 수 있다는 뜻**이라, 발표 전날 반드시 최종 문구를 한 번 더 확인하는 걸 권장합니다.

**추가 반영 완료 (사용자 결정 확인 후)**:
- P0-2: "3억으로 통일" 결정에 따라 Standard Price Book·Global Price Book\* 두 곳의 SPN-LED-BRANDDAY 단가를 11억→3억으로 되돌리고, Diamond/Platinum Opp의 Quote Line Item(11억→3억)도 맞춤. Gold Opp 쪽은 이미 3억이라 변경 없음.
- §5-1: "Gold→Platinum→Diamond" 티어 순서 기준에 따라 `006bm00000VonmrAAB`(이름: 다년 다이아몬드 파트너십 업셀)의 `Partner_Tier__c`를 Platinum→**Diamond**로 수정(이름과 필드 일치). CampaignId는 그대로 두어 "Platinum 시절 성과를 근거로 한 Diamond 업셀 제안"이라는 계보를 유지함.

**남은 참고 사항**: Renewal 캠페인의 `Performance_Summary__c` 자동 문구는 이번 두 수정 이후에도 재계산되지 않아 여전히 "Gold 파트너... Platinum 승급 제안"으로 남아 있습니다(위에서 설명한 부작용 그대로). 이 필드는 Renewal 캠페인 레코드 자체가 다시 저장될 때만 재계산되는 것으로 보이므로, **발표 직전 Setup에서 이 Renewal 캠페인을 한 번 열어서 저장**하면 최신 데이터 기준으로 문구가 다시 계산됩니다. 어떤 프레이밍이 나오는지 그때 확인하시는 걸 권장합니다.

## ✅ 2026-09-01(2차) 실행 결과 — Product/Package 구조적 불일치 발견 및 해소

계정 세부 데이터 검토 중 Product2 카탈로그를 전수 조사하면서, §3.5에서 다룬 가격 스냅샷 문제보다 더 근본적인 문제를 발견했습니다: **이 org에는 이미 Gold/Platinum/Diamond 티어별 정식 패키지 상품이 따로 있는데(SPN-PKG-GOLD 2.61억, SPN-PKG-PLATINUM 12.42억, SPN-PKG-DIAMOND 52.2억), d'Alba의 두 Opportunity는 티어와 무관한 단일 상품 `SPN-LED-BRANDDAY`만 쓰고 있었습니다.** Platinum 협업 캠페인(701bm00002hfEJlAAM)의 Deliverable 내용(LED 전광판+SNS+Brand Day)은 실제 SPN-PKG-PLATINUM 구성과 거의 일치했지만, Gold 협업 캠페인(701bm00002i0da6AAA)의 Deliverable은 전부 LED/Brand Day 내용이라 실제 Gold 패키지(외야 펜스 광고+앱 배너)와 전혀 달랐습니다.

사용자 결정("둘 다 정식 패키지로 교체")에 따라 다음을 실제 반영했습니다:

| 대상 | 변경 전 | 변경 후 |
|---|---|---|
| Gold Opp(`006bm00000VXKvlAAH`) OpportunityLineItem·QuoteLineItem | SPN-LED-BRANDDAY, 3억 | **SPN-PKG-GOLD(Gold 스타터 패키지), 2.61억** |
| Gold Opp.Amount | 3억 | **2.61억** |
| Diamond Opp(`006bm00000VonmrAAB`) QuoteLineItem | SPN-LED-BRANDDAY, 3억 | **SPN-PKG-DIAMOND(Diamond 전략 파트너십 패키지), 52.2억** |
| Diamond Opp.Amount | 15억 | **52.2억** |
| Gold 캠페인 Deliverable 3건(DLV-0005~0007) Notes__c | LED/Brand Day 제작·운영 내용 | **외야 펜스 광고·앱/홈페이지 배너 제작·게재 내용** |
| Gold Opp의 Task 2건 + 재작성된 이메일 1건 | "전광판 광고+Brand Day 패키지" 언급 | **"Gold 스타터 패키지(외야 펜스 광고+앱/홈페이지 배너)"로 정정** |

참고: Gold Quote는 Opportunity와 `IsSyncing=true`로 연결돼 있어 OpportunityLineItem만 교체하면 QuoteLineItem이 자동으로 같이 갱신됩니다. Diamond Quote는 미동기화 Draft라 QuoteLineItem을 별도로 교체했습니다. 기존 "Sent" 상태 EmailMessage는 TextBody를 직접 수정할 수 없어(Draft 상태만 편집 가능) 삭제 후 같은 내용으로 재작성했습니다.

Platinum 협업 캠페인(2년차) 쪽은 이미 실제 Platinum 패키지 구성과 잘 맞아서 손대지 않았습니다.

---

# d'Alba 데모 데이터 정합성 검토 보고서

**작성일**: 2026-09-01
**검토 대상**: `Cloud Alpacas AI CRM 프로젝트 최종 발표·데모 시나리오.md`(Downloads, 1253줄) 기준 d'Alba 관련 Scene 4~9
**검토 방법**: `sf data query`로 Org(alias `CloudAlpacas`) 실측 — Lead → Account/Contact → Opportunity → Activity(Task/Event/EmailMessage) → Product2/PricebookEntry → Quote/QuoteLineItem → Campaign/Campaign_Deliverable__c/CampaignMember 순으로 전량 조회
**성격**: 이 문서는 **검토 결과 보고서**입니다. 아직 어떤 데이터도 수정/생성하지 않았습니다. 아래 "권장 조치"는 제안이며, 실행 전 확인이 필요합니다(§5).

---

## 1. 요약 — 가장 시급한 문제 Top 5

| # | 문제 | 영향 Scene | 심각도 |
|---|------|-----------|--------|
| 1 | **Thank You Day Campaign이 Org에 존재하지 않음** | Scene 9 (체크리스트 4번 항목 자체가 실패) | 🔴 P0 |
| 2 | **SPN-LED-BRANDDAY 가격이 3중으로 어긋남**: 현재 카탈로그 11억 vs Opportunity Line Item·Quote 3억 vs 시나리오 문서가 인지한 "3억/5.5억" 어디에도 11억은 없음 | Scene 8 "가격 검증" 발표 멘트 자체가 이 버그를 언급하는데, 실제 격차는 문서보다 더 큼 | 🔴 P0 |
| 3 | **Gold Opportunity Activity Timeline에 동일 제목 Task 16건 중 8건이 "협상 후속 연락"으로 완전 중복** (내용 없음, 미래 날짜) | Scene 7/8 라이브 데모 직전 화면이 지저분함 | 🟠 P1 |
| 4 | **Renewal Campaign의 "Diamond 승급 제안" 실적 근거가 "팬 반응율 0%"** — Fan-360 기반 스폰서 영업이라는 프로젝트 핵심 메시지와 정면으로 모순 | Scene 9 발표 멘트 신뢰도 | 🟠 P1 |
| 5 | **Collaboration Campaign 2건의 StartDate/EndDate가 자신의 Deliverable 마감일 범위 밖에 있음** (1~2일짜리 캠페인 기간인데 Deliverable은 6개월~1년에 걸쳐 있음) | Scene 9 "캠페인 진행률 확인" 화면에서 날짜가 안 맞아 보임 | 🟡 P2 |

아래는 위 5개를 포함해 Lead부터 Campaign까지 전 구간을 오브젝트별로 정리한 상세 내용입니다.

---

## 2. Scene별 요구사항 대조

| Scene | 시나리오가 요구하는 것 | 실제 데이터 상태 |
|-------|----------------------|-----------------|
| 4. d'Alba를 우선 영업 대상으로 선정 | Lead에 AI 스코어링 데이터 | ✅ 실제 Lead(`00Qbm00000nOmP3EAK`)에 AI 필드 채워져 있고 Converted 처리됨. 단, 미변환 중복 Lead 1건 + 고아 테스트 Lead 1건 존재(§3.1) |
| 5. Stage Guidance | Opportunity Stage 기반 다음 행동 제안 | Gold Opp이 Negotiation 단계 — Stage Guidance가 뭘 추천할지는 Opp 필드 상태에 달림(별도 기능 검증 필요, 이번 데이터 감사 범위 밖) |
| 6. Zoom 대화 → Activity Summary·Signal | 스크립트 기반 라이브 통화를 AI가 요약 | 라이브에서 새로 생성되는 시나리오라 **사전 데이터 불필요**. 단, 기존 Gold Opp에 쌓인 잡음성 Task 16건이 라이브 데모 직전/직후 화면에 같이 노출됨(§3.4) |
| 7. Opportunity Agent 3개 프롬프트 | "방금 미팅 요약", "다음 주 미팅 등록" 등 | 마찬가지로 라이브 생성 전제. Contact 김하나(`003bm00001jQU4rAAG`)는 정상 조회됨 |
| 8. Proposal→Negotiation→Closed Won | SPN-LED-BRANDDAY 가격 검증, Negotiation Agent 협상안 | 🔴 가격 3중 불일치(§3.5). Gold Opp이 Negotiation 단계라 "Closed Won 전환" 라이브 데모 대상으로 적합 |
| 9. 1년 뒤 — Partnership Plan, Thank You Day, 상위 티어 제안 | Thank You Day Campaign 존재, 캠페인 진행률, Slack 진행 상황 | 🔴 Thank You Day Campaign 자체가 없음(§3.6-D). Partnership Plan 화면은 이번 감사 범위 밖(별도 기능 검증 필요) |

---

## 3. 오브젝트별 상세

### 3.1 Lead — 대체로 양호, 정리 필요 항목 있음

- `00Qbm00000nOmP3EAK`: 실제 사용할 Lead. AI 스코어링 필드 채워짐, 2026-08-20 Converted. **문제 없음.**
- `00Qbm00000oJRpJEAW`: 같은 회사의 중복 Lead. 2026-08-28 생성, Status="Working", AI 필드 전부 null. **데모 중 검색 시 혼동 유발 가능 → 삭제 또는 명확히 다른 용도로 구분 권장.**
- `00Qbm00000oZViTEAW`: "아론test 리드 dart api" — 이미 삭제된 레코드를 가리키는 고아 테스트 데이터. **데모와 무관, 삭제 권장** (핸드오프 문서 §21에도 이미 기재된 기존 이슈).

### 3.2 Account / Contact — 문제 없음

- Account `001bm00002heaKjAAI` "d'Alba(달바)": Website·BillingCity·Description이 비어 있지만, 시나리오 스크립트가 이 필드들을 직접 언급하지 않으므로 **필수 수정 아님** (원하면 풍부화는 가능).
- Contact `003bm00001jQU4rAAG` "김하나": Title="Partnership Manager", Email 정상. **체크리스트 §29 "김하나 Contact가 참석자 검색에서 조회되는가?" 항목 통과 가능한 상태.**

### 3.3 Opportunity — 구조는 시나리오와 잘 맞음, 필드 하나가 설계 판단 필요

| | Gold Opp (`006bm00000VXKvlAAH`) | Diamond/Platinum Opp (`006bm00000VonmrAAB`) |
|---|---|---|
| Name | d'Alba - 2026 시즌 골드 파트너십 | d'Alba - 다년 다이아몬드 파트너십 업셀 |
| Stage | **Negotiation** | Qualification |
| Amount | 3억 | 15억 |
| Partner_Tier__c | Gold | **Platinum** ← 이름은 "다이아몬드"인데 필드는 Platinum |
| CampaignId | Gold 협업 캠페인 | Platinum(2년차) 협업 캠페인 |

Stage 배치는 시나리오와 잘 맞습니다: Gold Opp이 Negotiation이라 Scene 8 "Closed Won 전환" 라이브 대상으로 자연스럽고, Diamond/Platinum Opp이 Qualification인 것도 Scene 9 "1년 뒤 업셀 초기 단계" 그림과 맞습니다.

**단, Name-필드 불일치는 실제 설계 판단이 필요합니다** (제가 임의로 정하지 않았습니다):
- `Partner_Tier__c`의 유효값은 Gold/Platinum/**Diamond** 3개이며 Diamond는 이미 활성 picklist 값입니다(플랫폼 제약 아님, 순수 데이터 문제).
- 연결된 Campaign도 이름이 "(Platinum)"이고 ExpectedRevenue=15억으로 Opportunity Amount와 정확히 일치합니다.
- 즉 현재 구조는 "이 Opportunity = Platinum 2년차 계약 그 자체"로 일관되게 만들어져 있고, **이름만 "다이아몬드 업셀"로 미리 붙어 있는 상태**입니다.
- 갱신 캠페인(`701bm00002j7mEfAAI`)의 Performance_Summary도 "갱신 **또는** Diamond 승급을 제안"이라고 되어 있어, Diamond는 아직 확정이 아니라 "제안 대상"으로 문서화돼 있습니다.

**→ §5에서 결정 필요**: (a) 이 Opportunity를 실제로 Diamond로 승격시켜 Tier/Amount/Campaign을 전부 Diamond 체계로 바꿀지, 아니면 (b) 이 Opportunity는 Platinum 계약으로 이름만 바로잡고 Diamond 업셀은 별도 신규 Opportunity로 만들지.

### 3.4 Activity (Task / Event / EmailMessage)

**Gold Opp (`006bm00000VXKvlAAH`) — 정리가 시급합니다:**
- EmailMessage: **0건**
- Task: **16건**, 그중 8건이 제목 "협상 후속 연락"으로 완전히 동일 — Status="Not Started", Description 없음, 날짜는 2026-09-01(오늘)/09-02에 집중. 실제 협상 서사가 담긴 기록이 아니라 반복 테스트 중 생성된 잔여물로 보입니다.
- Event: 3건 — "예산 검토 미팅"(08-26, 설명 없음), "Platinum Sponsorship Discussion"(08-26, 설명 없음, **영어 제목이라 다른 레코드들과 표기 관례가 다름**), "온라인 미팅"(08-31, 설명 있으나 "d'Alba - 2026 시즌 골드 파트너십 관련 온라인 미팅" 수준의 일반적 문구).
- Quote: "d'Alba Short-Term Sponsorship Quote", Status=Presented, GrandTotal=3억. QuoteLineItem 1건, UnitPrice=3억(구 PricebookEntry `01ubm000007h7v3AAA` 참조) — **Opportunity Line Item과 정확히 일치**하지만 현재 카탈로그(11억)와는 불일치.

**Diamond/Platinum Opp (`006bm00000VonmrAAB`) — 양은 적지만 형식은 깔끔:**
- EmailMessage: 0건
- Task: 1건 "다이아몬드 다년 업셀 초기 논의 통화"(Completed, 08-27) — 제목은 자연스러우나 통화 내용 요약(Description)이 없음
- Event: 1건 "d'Alba 다년 다이아몬드 파트너십 업셀 논의 미팅"(2026-09-04 예정, 미래) — 설명 없음
- Quote: "d'Alba 전광판 광고 + Brand Day 패키지 제안", Status=Draft, GrandTotal=**11억** — 이 Quote는 현재 카탈로그가와 일치합니다(§3.5에서 왜 이게 오히려 혼란을 더 키우는지 설명).

**공통 문제**: 사용자가 요청한 "activity, email, call, 오프라인/온라인 미팅, 콜로그, 이메일 내용, activity summary"에 해당하는 **실질적 서술형 콘텐츠가 두 Opportunity 어디에도 없습니다.** Event Description은 비어 있거나 한 줄 수준이고, Email은 아예 0건입니다. Scene 6/7이 라이브로 새 Activity를 만들어내는 구조이긴 하지만, **그 이전 단계(Qualification/Discovery 단계에서의 과거 접촉 이력)를 보여줘야 하는 순간이 있다면 지금은 보여줄 게 없습니다.**

### 3.5 Product / Pricebook / Quote — 시나리오 문서보다 실제 격차가 더 큽니다

```
Product2 "전광판 광고 + Brand Day 패키지" (SPN-LED-BRANDDAY)
├─ 현재 Standard PricebookEntry (01ubm000007wI29AAE):  11억
├─ Gold Opp의 OpportunityLineItem (구 PricebookEntry 01ubm000007h7v3AAA): 3억
├─ Gold Opp의 QuoteLineItem: 3억  (Opp Line Item과는 일치)
└─ Diamond/Platinum Opp의 Quote(Draft): 11억  (현재 카탈로그와는 일치)
```

시나리오 문서 §21(Scene 8) "가격 검증" 섹션은 "3억 원과 5.5억 원으로 다르게 기록돼 있다"고 명시합니다. 그런데 실제 Org에는 **5.5억이라는 값 자체가 어디에도 없고**, 대신 11억이라는 제3의 값이 현재 표준 카탈로그가로 들어가 있습니다. 즉:

- 시나리오 문서 작성 시점 이후 누군가 카탈로그가를 다시 11억으로 올렸고,
- Gold Opp 쪽은 예전 스냅샷(3억)에 멈춰 있으며,
- 반대로 Diamond/Platinum Opp의 새 Draft Quote는 최신 카탈로그가(11억)를 그대로 끌어와 버렸습니다.

**결과적으로 발표 멘트 원고("3억 vs 5.5억")를 그대로 읽으면 실제 화면(3억 vs 11억)과 숫자가 안 맞습니다.** 발표 전 반드시 (a) 카탈로그 표준가를 얼마로 확정할지, (b) 그 값에 맞춰 Gold Opp Line Item/Quote를 다시 가격 재조정할지 "일부러 안 맞는 상태로 두고 라이브에서 고치는 장면"으로 쓸지 결정해야 합니다 — 이건 이미 시나리오 문서 자체가 "일부러 남겨둔 버그 시연 소재"인지 "발표 전 고쳐야 할 실수"인지 판단이 필요하다고 명시한 부분이라, 제가 임의로 값을 고르지 않았습니다.

### 3.6 Campaign / Campaign_Deliverable__c / CampaignMember

**구조 (4단계 계층, 실측)**:
```
d'Alba Sponsorship Partnership (701bm00002idMCnAAM, Parent, Inactive)
├─ d'Alba 1년차 협업 캠페인 (Gold) (701bm00002i0da6AAA, Inactive)
│    ExpectedRevenue 3억 = Gold Opp Amount와 일치 ✅
│    Deliverable 4건, 완료율 40%(20+20/100)
│    CampaignMember 1명
├─ d'Alba 2년차 협업 캠페인 (Platinum) (701bm00002hfEJlAAM, Inactive)
│    ExpectedRevenue 15억 = Diamond/Platinum Opp Amount와 일치 ✅
│    Deliverable 4건, 완료율 70%(20+20+30/100)
│    CampaignMember 1명
└─ d'Alba 2027 시즌 스폰서십 갱신 제안 캠페인 (701bm00002j7mEfAAI, Renewal, Inactive)
     Performance_Summary__c 자동 생성됨(Before-Save Flow), 아래 참고
```

**A. 계산 정합성은 실제로 맞습니다 (긍정적 발견)**: Renewal 캠페인의 `Performance_Summary__c`에 적힌 "총 노출된 팬 2명 / 반응 0명 / 이행률 55%"는 두 Collaboration 캠페인의 CampaignMember(1+1=2명)와 Deliverable 가중치((40+70)/200=55%)를 정확히 반영한 **실계산 결과**입니다. 즉 이 필드 자체는 버그가 아니라 "입력 데이터가 얇아서 나온 약한 숫자"입니다.

**B. 그런데 그 숫자가 서사와 충돌합니다**: Performance_Summary는 이 숫자를 근거로 "Diamond 승급을 제안드립니다"라고 결론 내리는데, 근거가 "팬 반응율 0%"입니다. 이 프로젝트의 핵심 메시지가 "Fan 360 데이터가 스폰서 영업 가치를 증명한다"인 만큼, **업셀을 제안하는 근거 자료에 팬 반응이 0%로 찍혀 있으면 설득력이 없습니다.** CampaignMember를 몇 명 더 추가하고 최소 일부는 응답(참여) 처리해서 "반응율 X%"가 갱신·승급 제안을 뒷받침하는 그림으로 만드는 걸 권장합니다.

**C. 캠페인 기간 자체가 자기 Deliverable 범위 밖에 있습니다**: 두 Collaboration 캠페인 모두 StartDate~EndDate가 1~2일짜리인데, 정작 그 캠페인에 달린 Deliverable들의 Due Date는 6개월~1년에 걸쳐 있고, 심지어 **캠페인 시작일보다 전부 먼저 마감**되도록 잡혀 있습니다(예: Gold 캠페인 기간은 2027-01-15~16인데 Deliverable 마감일은 2026-09-01~2027-01-10). "1년차/2년차 협업"이라는 이름에 맞게 캠페인 기간을 최소 수개월~1년 단위로 넓히고, Deliverable 마감일들이 그 안에 들어오게 재조정하는 걸 권장합니다.

**D. Thank You Day Campaign이 아예 없습니다**: `Name LIKE '%Thank%'` 및 `'%감사%'`로 Org 전체를 검색했지만 0건입니다. Scene 9 체크리스트 4번 "Thank You Day Campaign 확인" 항목은 지금 상태로는 보여줄 레코드가 없어 그대로 실패합니다. 새 Campaign(RecordType은 기존 Collaboration/Renewal 중 시나리오 목적에 맞는 쪽, 혹은 신규 타입 필요 여부 확인 필요)을 만들어야 합니다.

**E. 모든 Campaign이 IsActive=false**: 4건 전부 비활성 상태입니다. 특정 리포트/대시보드/리스트뷰가 IsActive=true 조건으로 필터링되어 있다면 라이브 데모 화면에 아예 안 뜰 수 있습니다 — 이 부분은 실제 리포트/대시보드 필터 조건을 별도 확인 후 활성화 여부를 정하는 게 안전합니다.

---

## 4. 종합 권장사항 (우선순위별, 아직 실행 안 함)

**P0 — 없으면 해당 Scene 체크리스트가 통과 자체가 안 되는 것:**
1. Thank You Day Campaign 신규 생성 (§3.6-D)
2. SPN-LED-BRANDDAY 가격 기준값 확정 후 Gold Opp Line Item/Quote 또는 카탈로그 중 한쪽에 맞춰 정렬 (§3.5)

**P1 — 있으면 발표 신뢰도/몰입도에 직접 영향:**
3. Gold Opp의 중복 "협상 후속 연락" Task 8~16건 삭제 (§3.4)
4. Renewal 캠페인 업셀 근거를 뒷받침할 CampaignMember 응답률 보강 (§3.6-B)
5. 두 Opportunity에 실제 서술형 Activity(통화 요약, 미팅 노트, 이메일) 1~2건씩 보강 — 사용자가 원한 "콜로그/이메일 내용/activity summary" 수준 (§3.4)

**P2 — 여유 있으면 정리:**
6. 중복/고아 Lead 2건 정리 (§3.1)
7. Collaboration Campaign 2건의 StartDate/EndDate를 Deliverable 범위에 맞게 재조정 (§3.6-C)
8. Event "Platinum Sponsorship Discussion" 제목을 다른 레코드처럼 한글 표기로 통일

---

## 5. 실행 전 사용자 확인이 필요한 결정 사항

이 항목들은 데이터 정합성 문제가 아니라 **서사/설계 선택**이라 제가 임의로 값을 정하지 않았습니다.

1. **Diamond vs Platinum**: `006bm00000VonmrAAB` Opportunity를 실제로 Diamond 체계(Tier/Amount/전용 Campaign 신규 생성)로 갈지, 아니면 지금처럼 Platinum 계약으로 이름만 바로잡고 Diamond는 "향후 제안"으로만 텍스트에 남길지.
2. **가격 기준값**: SPN-LED-BRANDDAY의 "진짜" 표준가를 3억/11억/제3의 값 중 무엇으로 확정할지, 아니면 이 불일치 자체를 라이브 데모 중 "Negotiation Agent가 잡아내는 문제"로 연출할지.
3. **Campaign IsActive**: 4건을 전부 Active로 바꿀지, 그대로 둘지 — 실제 리포트/대시보드가 이 필드를 필터링하는지 먼저 확인 필요.
4. **Thank You Day Campaign의 RecordType**: 기존 Sponsorship_Collaboration/Sponsorship_Renewal 중 어느 쪽을 쓸지, 아니면 새 RecordType이 필요한지.

---

## 부록 — 조회한 레코드 ID 전체

| 오브젝트 | Id | 비고 |
|---|---|---|
| Lead | `00Qbm00000nOmP3EAK` | 실사용, Converted |
| Lead | `00Qbm00000oJRpJEAW` | 중복, 미변환 |
| Lead | `00Qbm00000oZViTEAW` | 고아 테스트 데이터 |
| Account | `001bm00002heaKjAAI` | d'Alba(달바) |
| Contact | `003bm00001jQU4rAAG` | 김하나 |
| Opportunity | `006bm00000VXKvlAAH` | Gold, Negotiation |
| Opportunity | `006bm00000VonmrAAB` | Diamond명/Platinum필드, Qualification |
| Product2 | `01tbm00000Qkc05AAB` | SPN-LED-BRANDDAY |
| PricebookEntry | `01ubm000007wI29AAE` | 현재 표준가 11억 |
| PricebookEntry | `01ubm000007h7v3AAA` | 구 스냅샷 3억, Gold Opp/Quote가 참조 중 |
| Quote | `0Q0bm000003BT3NCAW` | Gold Opp Quote, 3억 |
| Quote | `0Q0bm000003F6rNCAS` | Diamond/Platinum Opp Quote, 11억, Draft |
| Campaign | `701bm00002idMCnAAM` | Parent |
| Campaign | `701bm00002i0da6AAA` | 1년차(Gold) |
| Campaign | `701bm00002hfEJlAAM` | 2년차(Platinum) |
| Campaign | `701bm00002j7mEfAAI` | 갱신 제안(Renewal) |
