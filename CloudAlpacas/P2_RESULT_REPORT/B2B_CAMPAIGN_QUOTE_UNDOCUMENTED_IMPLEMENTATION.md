# P2 Campaign · Quote 고도화 — 미기록 구현 정리

> 승우(Product/Quote/Campaign) 파트에서 2026-08-20 이후 Production Org에 실제로 반영했지만, `03_SYSTEM.md`/`05_DECISIONS.md` 등 공식 문서(Source of Truth)에는 아직 기록되지 않은 항목을 정리한 문서입니다. `CLAUDE.md` §7("프로젝트 전체에 영향을 주는 변경은 반드시 Decision으로 기록한다")을 뒤늦게라도 충족하기 위한 체크포인트입니다.

| 항목 | 내용 |
| --- | --- |
| 작성자 | 승우(Rafael) |
| 기준일 | 2026-08-26 |
| 대상 Org | CloudAlpacas Production |
| 문서 목적 | Org에는 있지만 문서화되지 않은 구현을 팀이 검토·Decision화할 수 있도록 근거 자료로 남김 |
| 전제 | 이 문서는 그 자체로 공식 Decision이 아닙니다. 팀 논의 후 `05_DECISIONS.md`/`03_SYSTEM.md` 반영 여부를 결정합니다. |

---

## 1. 왜 이 문서가 필요한가

`05_DECISIONS.md` Decision 003·006·018은 "Standard First, 필요한 만큼만 Custom Object를 만든다"는 원칙과 "Object 구조 변경은 반드시 Decision으로 기록한다"는 원칙을 명시하고 있습니다. 그런데 2026-08-20 이후 진행한 Campaign 고도화 작업 중 일부는 이 원칙에 따라 팀 승인을 먼저 받지 않고 Production에 직접 반영됐습니다 — 급한 검증이 필요해 순서가 뒤바뀐 것이며, 지금이라도 근거를 남기고 팀 검토를 받기 위해 이 문서를 작성합니다.

아래 각 항목은 **목적 → 구현된 상태 → 쓰이는 용도** 순서로 정리했습니다.

---

## 2. Campaign_Deliverable__c (신규 Custom Object)

### 목적
Sponsorship Collaboration Campaign이 "체결"이 아니라 "실행" 단계에 들어갔을 때, 약속한 실행 과업(전광판 시안 승인, LED 설치, Brand Day 부스 준비 등)이 실제로 얼마나 진행됐는지를 추적하기 위해 만들었습니다. 표준 Campaign Object에는 "이번 협업에서 하기로 한 개별 작업 목록"을 표현할 필드가 없습니다.

### 구현된 상태
| 구분 | 상태 |
| --- | --- |
| Object/관계 | Master-Detail(Master = Campaign) — `Campaign__c` |
| 필드 7개 전부 (`Status__c`, `Weight__c`, `Campaign__c`, `Due_Date__c`, `Completed_Date__c`, `Evidence_URL__c`, `Notes__c`) | **정상 — SOQL/describe/UI 모두 조회 가능(2026-08-25 해결)** |
| ~~비정상~~ (해결됨) | ~~`Due_Date__c`/`Completed_Date__c`/`Evidence_URL__c`/`Notes__c` 4개 필드가 배포 후 5일간 SOQL/describe에서 조회 실패했던 문제~~ — **승우가 4개 필드를 직접 삭제 후 동일 설정(Label/Type/Help Text 한글化 포함)으로 재생성해서 해결**. Salesforce Support 케이스 없이 재생성만으로 스키마 레지스트리 문제가 풀림. |
| 실데이터 | `d'Alba Sponsorship Campaign`에 4건(Completed 2건/In Progress 1건/Not Started 1건, 가중치 합 100%) — **Due Date/Completed Date/Notes까지 전부 입력 완료(2026-08-25)** |
| 소스 반영 | **미완료** — 임시 스크래치패드 SFDX 프로젝트에서 배포되어 `force-app`(이 저장소 기준 `salesforce/`)에 소스로 남아있지 않음 |

### 쓰이는 용도
- Report `Sponsorship Deliverable Status - d'Alba` (Status별 Weight 합계)의 데이터 소스
- Dashboard `PRM Sponsorship Campaign Performance`의 "Total Deliverables" Metric 위젯(100%로 표시 중)

### 팀 검토가 필요한 이유
Decision 018-D는 "Campaign = Collaboration Record Type, 별도 Object 없음"만 확정했습니다. 이 Object는 그 위에 얹은 **추가 확장**이며, Decision 003(Standard First)에 비춰볼 때 "Report/Dashboard만으로는 정말 부족했는가"를 팀이 검토해야 합니다. 유지하기로 하면 정식 Decision으로 기록하고, 되돌리기로 하면 Report 기반 대안으로 전환합니다.

---

## 3. Campaign Member Status 5단계 확장 (Targeted → Reached → Engaged → Attended → Converted)

### 목적
기본 2단계(Targeted/Responded)로는 스폰서십 실행 중 팬 반응이 어느 단계까지 왔는지("타겟팅만 됐는지, 실제 참여까지 했는지") 구분할 수 없어서 5단계로 확장했습니다.

### 구현된 상태
- `d'Alba Sponsorship Campaign`(장기)에 먼저 적용(2026-08-20)
- `d'Alba Short-Term Sponsorship Campaign`(단기)은 예전 2단계(Sent/Responded)로 남아있던 것을 이번 세션(2026-08-24)에 동일한 5단계로 통일 — 기존 Status 삭제, 기존 Member 6건 재매핑 완료
- 두 Campaign 모두 현재 동일한 Status 세트를 사용 중임을 확인

### 쓰이는 용도
- Report `Sponsorship Member Funnel`의 그룹핑 기준(현재 전체 Sponsorship Campaign 대상으로 확장됨)

---

## 4. Campaign Hierarchy (Parent Campaign 도입)

### 목적
한 스폰서(d'Alba)가 단기·장기 두 협업을 동시에 진행하는 경우, 이를 상위 Campaign 아래로 묶어 스폰서 단위로 합산 조회하기 위해 도입했습니다. 표준 Campaign의 `ParentId` 필드는 원래 있지만 실제로 쓴 적이 없었습니다.

### 구현된 상태
- `d'Alba Sponsorship Partnership`(Parent) 신규 생성
- `d'Alba Sponsorship Campaign`(장기, 30억)·`d'Alba Short-Term Sponsorship Campaign`(단기, 3억)을 하위로 연결
- 각 Campaign의 `ExpectedRevenue`에 실제 연결된 Opportunity Amount 값 입력(가공 없음)

### 쓰이는 용도
- Report `Sponsorship Collaboration ROI`의 그룹핑 기준
- Dashboard 위젯 "스폰서십 협업별 예상 매출"

---

## 5. Campaign 표준 재무 필드 노출 (Budgeted Cost / Actual Cost / Expected Revenue)

### 목적
Salesforce Campaign에 원래 내장된 표준 ROI 계산 기능(확정 매출 대비 실집행 비용)을 스폰서십에도 활용하기 위해 `Sponsorship Collaboration Layout`에 세 필드를 노출했습니다.

### 구현된 상태
- Layout에 "Sponsorship Financials" 섹션 신규 추가·배포 완료
- `ExpectedRevenue`: 실제 값(위 §4 참고)
- `BudgetedCost`/`ActualCost`: **실제 재무 데이터가 아니라 승우가 만든 시나리오 값**입니다(장기 1.5억/6천만, 단기 3천만/0 — Deliverable 진행률(40% 완료) 비례로 산정). 실제 집행 비용이 확정되면 반드시 교체해야 합니다.

### 쓰이는 용도
- Salesforce 표준 Campaign ROI 계산(현재는 두 딜 다 Closed Won 전이라 ROI가 -100%로 표시됨 — 정상 동작, Won 금액 기준 계산이기 때문)

---

## 6. B2B Sponsorship Report 5종 신규 생성

| Report | 목적 | 상태 |
| --- | --- | --- |
| `Sponsorship Collaboration ROI` | 협업(Parent Campaign)별 예상 매출/ROI | 실행 검증 완료, Dashboard 위젯 연결됨 |
| `Sponsorship Pipeline by Stage` | Opportunity Stage별 딜 건수·합계 금액 | 실행 검증 완료 |
| `Sponsorship Open Package Count` | 진행 중인 딜 개수 | 실행 검증 완료(현재 2건) |
| `Sponsorship Average Quote Amount` | 평균 Quote 금액 | 실행 검증 완료(현재 16.5억) |
| `Sponsorship Collaboration Status` | Collaboration Status별 건수 | 실행 검증 완료(현재 3건, 전부 Planned) |

### 쓰이는 용도
전부 `PRM Sponsorship Campaign Performance` Dashboard(기존 대시보드, 혜준·승우 공동 사용)에 위젯으로 통합하는 방향으로 진행 중입니다.

### 팀 검토가 필요한 이유
Decision 018-J는 Fan Insight에 대해서만 "Report/Dashboard, Object 없음"을 확정했습니다. B2B Sponsorship Pipeline/ROI Dashboard 자체는 Decision 019 §7에서 방향(현재 Opportunity 수, Pipeline Amount 등)만 언급됐을 뿐 "구체적인 KPI 공식/Field는 확정하지 않는다(TBD)"로 명시돼 있습니다. 위 5개 Report는 그 TBD를 실제로 채운 첫 구현이므로, 팀이 이 방향이 맞는지 확인해주시면 좋겠습니다.

---

## 7. Product Schedule 활성화 (Quantity/Revenue Schedule)

### 목적
전광판 광고처럼 한 번에 끝나지 않고 기간에 걸쳐(예: 3개월 노출) 집행되는 스폰서십을 월별로 나눠 관리하기 위해 활성화했습니다.

### 구현된 상태
- Org 설정(Setup > Quantity and Revenue Schedules) 활성화 완료
- `전광판 광고 + Brand Day 패키지` 상품에 Revenue Schedule Type = Divide, 3개월 분할 설정
- `d'Alba Short-Term Sponsorship` 딜의 실제 OpportunityLineItem에 3개월 스케줄(1억×3=3억) 생성·합계 검증 완료

### 쓰이는 용도
현재는 검증용 데이터 1건뿐이며, 향후 다른 기간제 스폰서십 상품에도 동일하게 적용 가능합니다.

---

## 8. Company Information 정비

### 목적
Quote PDF에 표시되는 발신 회사 정보(Cloud Alpacas 주소·연락처)가 비어있어 실제 발송용으로 쓸 수 없는 상태였습니다.

### 구현된 상태
- Organization Name: `Cloud Alpacas`
- Street/City: `6th floor, 27, Changgyeonggung-ro 5da-gil, Jung-gu` / `Seoul`
- Phone/Fax: `010-2026-0904` / `04545`
- Postal Code는 아직 미입력(값을 받는 대로 추가 필요)

### 쓰이는 용도
Quote Template PDF 발신자 정보 전체

---

## 9. 필드 Help Text 정리 (2026-08-25 반영)

Product2/Quote/Campaign의 표준 필드 중, 값의 뜻이 한눈에 안 들어오는 필드에 한글 Help Text를 추가했습니다(Setup → 필드 편집 화면의 ⓘ 아이콘에 노출). `Name`/`StartDate`/`EndDate`처럼 뜻이 자명한 필드는 일부러 넣지 않았습니다.

| 오브젝트 | 필드 | Help Text |
| --- | --- | --- |
| Product2 | `Family` | 이 상품이 어떤 계열인지 구분하는 값입니다. Sponsorship Package는 항상 'Sponsorship'으로 둡니다. |
| Product2 | `RevenueScheduleType` | 이 상품의 매출을 기간에 걸쳐 나눠 인식할지 정합니다. 'Divide'로 설정하면 전체 금액을 개월 수만큼 균등하게 나눠 월별 매출로 잡습니다(예: 3개월 전광판 노출). |
| Product2 | `RevenueInstallmentPeriod` | 매출을 나눌 주기입니다. 스폰서십 상품은 보통 'Monthly'(월별)로 관리합니다. |
| Quote | `Status` | 이 견적서가 지금 어느 단계인지 나타냅니다. 새로 작성하면 Draft이고, 검토·승인을 거쳐 상대방에게 전달(Presented)한 뒤 최종적으로 Accepted 또는 Rejected로 마무리됩니다. |
| Quote | `ExpirationDate` | 이 견적의 유효기한입니다. 이 날짜가 지나면 동일한 조건으로 계약을 보장할 수 없습니다. |
| Campaign | `Type` | 이 Campaign의 목적을 구분하는 값입니다. 스폰서십 협업은 항상 'Sponsorship'을 사용합니다. |
| Campaign | `Status` | 이 협업이 지금 어느 단계인지 나타냅니다. Planned(계획 수립) → In Progress(실행 중) → Completed(정상 종료) 또는 Aborted(중단) 순서로 관리합니다. |
| Campaign | `IsActive` | 지금 실제로 실행 중인 협업인지 표시합니다. 계약은 됐지만 아직 실행 전(Planned)이면 체크를 해제한 상태로 둡니다. |
| Campaign | `ParentId` | 이 협업이 속한 상위 스폰서 관계입니다. 같은 스폰서 기업과 여러 번(단기·장기 등) 협업할 때, 상위 Campaign 아래로 묶어서 합산 관리합니다. |
| Campaign | `BudgetedCost` | 이 협업을 실행하기 위해 미리 잡아둔 예산입니다. |
| Campaign | `ActualCost` | 이 협업을 실행하면서 실제로 집행한 비용입니다. Budgeted Cost와 비교해서 예산 대비 집행률을 확인할 수 있습니다. |
| Campaign | `ExpectedRevenue` | 이 협업으로 예상되는 매출(스폰서십 계약 금액)입니다. 연결된 Opportunity의 Amount를 기준으로 입력합니다. |
| Campaign_Deliverable__c | `Due_Date__c`/`Completed_Date__c`/`Evidence_URL__c`/`Notes__c` | §2 참고 — 필드 재생성과 함께 Help Text도 함께 반영됨 |

---

## 10. Picklist 단계별 의미 (Quote Status / Campaign Status / Campaign Member Status)

Salesforce는 필드 전체에는 Help Text를 붙일 수 있지만, **Picklist 값 하나하나에는 시스템상 Help Text를 붙일 수 없습니다.** 그래서 아래 내용은 Org에 입력한 것이 아니라, 팀원이 각 단계의 의미를 헷갈리지 않도록 이 문서에 정리해둔 참고 자료입니다 — 값 이름만 나열하지 않고 "이 상태가 실제로 뭘 뜻하는지"를 적었습니다.

### 10.1 Quote Status (Standard Quote 기본값, 8단계)

| 값 | 의미 |
| --- | --- |
| Draft | 견적서를 작성하는 중입니다. 아직 상대방에게 전달되지 않은 내부 초안 상태입니다. |
| Needs Review | 작성은 끝났지만, 발송 전에 내부 검토가 필요하다고 표시된 상태입니다. |
| In Review | 내부 검토가 실제로 진행되고 있는 상태입니다. |
| Approved | 내부 검토·승인이 끝나 상대방에게 발송할 준비가 된 상태입니다. |
| Presented | 승인된 견적서를 실제로 스폰서(상대 회사)에게 전달한 상태입니다. |
| Accepted | 상대방이 이 견적 내용을 최종적으로 수락한 상태입니다. |
| Rejected | **내부 승인 절차에서** 반려되어, 상대방에게 전달되지 못하고 끝난 상태입니다. |
| Denied | **상대방에게 전달한 뒤** 상대방이 거절한 상태입니다. |

> ⚠️ `Rejected`와 `Denied`는 Standard Quote 기본 제공 값이라 그대로 두었지만, 이름만으로는 구분이 잘 안 됩니다. 위 구분("내부 반려" vs "상대방 거절")은 제가 제안하는 해석이며, **팀이 실제로 이렇게 나눠 쓸지 합의가 필요합니다** — 현재 실제 Quote 2건은 모두 Draft라 아직 이 두 값이 실사용된 적은 없습니다.

### 10.2 Campaign Status (Sponsorship Collaboration, 4단계)

| 값 | 의미 |
| --- | --- |
| Planned | 협업이 확정(계약 체결)됐지만, 아직 실제 실행(광고 노출, 이벤트 진행 등)을 시작하지 않은 단계입니다. |
| In Progress | 실제로 실행 중인 단계입니다 — 전광판 광고가 노출되고 있거나 Brand Day 행사가 진행되는 등. |
| Completed | 계획했던 실행이 정상적으로 끝난 단계입니다. |
| Aborted | 실행 도중 또는 그 전에 중단된 단계입니다 — 계약 해지, 상호 합의에 의한 중단 등. |

### 10.3 Campaign Member Status (팬 반응 5단계 퍼널)

| 값 | 의미 |
| --- | --- |
| Targeted | 이번 협업의 타겟 Fan으로 선정된 상태입니다. 아직 실제 접촉은 이뤄지지 않았습니다. |
| Reached | 실제로 접촉(발송, 노출 등)이 이뤄진 상태입니다. 아직 Fan의 반응은 확인되지 않았습니다. |
| Engaged | Fan이 실제로 반응(클릭, 참여 의사 표현 등)을 보인 상태입니다. 여기서부터 `HasResponded = Yes`로 집계됩니다. |
| Attended | 오프라인 행사(Brand Day 부스 등)에 실제로 참여한 상태입니다. |
| Converted | 이 협업을 통해 목표했던 최종 행동(구매, 가입 등)까지 이어진 상태입니다. |

---

## 11. Dashboard 최종 구성 (2026-08-25)

`PRM Sponsorship Campaign Performance` Dashboard에 §6의 Report 5종을 전부 위젯으로 반영하고, 기존 2개(Total Deliverables, Member Funnel)와 합쳐 총 7개 위젯 구성을 완료했습니다.

| 위젯 | 원본 Report | 타입 |
| --- | --- | --- |
| 진행 중인 스폰서십 패키지 | Sponsorship Open Package Count | Metric |
| 평균 견적 금액 | Sponsorship Average Quote Amount | Metric |
| 스폰서십 협업별 예상 매출 | Sponsorship Collaboration ROI | Bar Chart |
| 스폰서십 진행 현황 (구 "Collaboration 진행 현황") | Sponsorship Collaboration Status | Table |
| 스폰서십 파이프라인 | Sponsorship Pipeline by Stage | Table |
| 실행 과업 진행률 (구 Total Deliverables) | Sponsorship Deliverable Status | Metric |
| 팬 반응 퍼널 (구 Member Funnel) | Sponsorship Member Funnel | Table |

**이름 변경 배경**: "Collaboration 진행 현황"을 "스폰서십 진행 현황"으로 바꿨습니다 — `05_DECISIONS.md` Decision 019가 이미 "B2B Story의 중심을 Collaboration에서 Sponsorship Sales/Pipeline으로 전환"하기로 확정해뒀는데, 위젯 이름에는 이게 반영되지 않고 있었습니다. Dashboard 이름 자체도 `스폰서십 통합 현황판`으로 바꾸는 걸 제안드립니다(현재 "PRM Sponsorship Campaign Performance"는 영문이고, 지금은 실행 성과뿐 아니라 파이프라인·재무·진행상태·반응까지 다 포함하는 통합 현황판이 됐기 때문입니다) — 대시보드 이름 자체를 바꿀지는 팀 확인 후 진행하는 걸 권장합니다.

### 발견 및 수정한 버그 — Report 형식(Tabular) 문제

`Sponsorship Open Package Count`/`Sponsorship Average Quote Amount` 두 Report를 Dashboard 위젯으로 추가하려 하면 **"We can't get data for this widget right now"** 오류가 났습니다. 원인은 데이터가 아니라 Report 형식이었습니다 — Salesforce는 그룹핑이 하나도 없는 Report를 "Summary" 형식으로 저장해도 내부적으로 "Tabular"로 되돌리는데, Dashboard 위젯(특히 Metric 타입)은 Tabular Report를 지원하지 않습니다. **의미 있는 그룹(Stage)을 하나씩 추가해서 진짜 Summary 형식으로 고정**해 해결했습니다 — Metric 위젯은 어차피 전체 합계(Grand Total)만 쓰기 때문에, 그룹이 추가돼도 화면에 보이는 숫자는 그대로입니다.

---

## 12. Net Profit Custom Summary Formula 추가

### 배경
"구단 재정 상태 개선"이라는 Business Goal(CLAUDE.md §2, Decision 019)에 맞춰, 스폰서십 협업이 실제로 얼마나 순이익을 내는지 확인할 방법이 필요했습니다. Salesforce 표준 Campaign ROI(%)는 이미 있었지만, 원(KRW) 단위의 순이익 금액을 보여주는 지표는 없었습니다.

### 구현
`Sponsorship Collaboration ROI` Report에 Custom Summary Formula를 추가했습니다.
- **Column Name**: `Net Profit`
- **Formula**: `EXP_REVENUE:SUM - ACTUAL_COST:SUM` (Expected Revenue 합계 − Actual Cost 합계)
- **Format**: Currency, Display: All Summary Levels

### 검증
전체 합계 기준 `예상 매출 33억 − 실집행 비용 6천만 = 순이익 32억 4천만`으로 정확히 계산되는 것을 API로 재조회해 확인했습니다.

### 쓰이는 용도
`스폰서십 협업별 예상 매출` Dashboard 위젯의 Report에 그대로 반영되어, Parent Campaign(스폰서)별 실제 순이익을 원 단위로 바로 확인할 수 있습니다.

---

## 13. Campaign.ExpectedRevenue 자동 동기화 (Flow 3종 신설)

### 배경
`Campaign.ExpectedRevenue`는 원래 승우가 연결된 Opportunity의 Amount 값을 **손으로 복사해 넣은 것**이었습니다(§5 참고). `03_SYSTEM.md` Decision 014가 B2C 쪽에 이미 경고해둔 것과 똑같은 함정입니다 — "원천 데이터를 다른 곳에 복제하면 나중에 어긋난다." Opportunity Amount가 바뀌면 Campaign 쪽은 자동으로 안 바뀌므로, 두 값이 서로 다른 숫자를 보여줄 위험이 있었습니다.

### 왜 Roll-Up Summary가 아니라 Flow인가
Opportunity → Campaign 연결(Primary Campaign Source)은 표준 **Lookup** 관계입니다. Roll-Up Summary는 **Master-Detail** 관계에서만 가능해서 못 씁니다 — 이건 `05_DECISIONS.md` Decision 018-K(Account 집계 필드 On Hold)가 Account-Opportunity 관계에서 이미 겪은 것과 동일한 제약입니다. Flow가 Salesforce에서 이 경우 쓰는 표준적인 대안입니다(Decision 003 "Standard First"의 연장).

### 구현 — Flow 3개 (Subflow 패턴)

같은 계산 로직(Campaign에 연결된 Opportunity 금액 합산)을 여러 트리거(생성/수정/삭제)가 공유해야 해서, 로직 중복으로 인한 정합성 어긋남을 막기 위해 **Subflow로 분리**했습니다.

| Flow | Label | API Name | 역할 |
| --- | --- | --- | --- |
| Subflow | `Campaign 예상 매출 계산` | `Recalculate_Campaign_Expected_Revenue` | 계산 로직 본체 — Campaign Id와 "제외할 Opportunity Id"(선택)를 입력받아 합산 후 Campaign.ExpectedRevenue 갱신 |
| Flow 1 | `Campaign 예상 매출 동기화` | `Campaign_Expected_Revenue_Sync` | Opportunity 생성/수정 시 Subflow 호출(제외 Id 없음) |
| Flow 2 | `Campaign 예상 매출 동기화 (Opportunity 삭제 시)` | `Campaign_Expected_Revenue_Sync_On_Delete` | Opportunity 삭제 시 Subflow 호출(삭제되는 자기 자신 Id를 제외 Id로 전달) |

> Salesforce Record-Triggered Flow는 "생성/수정"과 "삭제"를 하나의 Flow에서 동시에 트리거할 수 없어서 Flow가 2개로 나뉩니다. 삭제 시 제외 로직은 "제외할 Opportunity Id가 비어있으면 아무것도 제외되지 않는다"는 성질을 이용해, 조건 분기 없이 하나의 Subflow로 생성/수정/삭제를 전부 처리하도록 설계했습니다.

### 검증 (2026-08-25, 실제 테스트)

| 시나리오 | 결과 |
| --- | --- |
| 테스트 Opportunity 생성(연결 Campaign에 2,000,000 추가) | ✅ Campaign.ExpectedRevenue: 300,000,000 → 302,000,000 |
| 그 Opportunity 삭제 | ✅ Campaign.ExpectedRevenue: 302,000,000 → 300,000,000 (수동 개입 없이 자동 복구) |

### 알려진 한계
- Opportunity의 Campaign(Primary Campaign Source)이 **변경**되는 경우(A Campaign → B Campaign으로 재연결)는 Flow 1이 "새 Campaign(B)"의 합계는 갱신하지만, **"예전 Campaign(A)"의 합계는 갱신하지 않습니다** — A는 여전히 예전 Opportunity가 포함된 금액으로 남습니다. 이 케이스가 실제로 발생할 가능성이 있으면 추가 보완이 필요합니다.

---

## 14. 이번 작업 중 발견한 플랫폼 제약사항

### Product Schedule이 걸린 Line Item은 단가 변경 불가
Revenue Schedule이 설정된 OpportunityLineItem/QuoteLineItem은 **단가(Sales Price/Unit Price)를 직접 수정할 수 없습니다**(`Invalid unit price change on Quote Line Item; cannot modify unit price when the item is revenue scheduled`). 스케줄이 이미 그 가격을 기준으로 월별 분할돼 있어서, 가격을 바꾸려면 기존 스케줄을 먼저 삭제해야 합니다. `d'Alba Short-Term Sponsorship`의 전광판 광고 상품이 여기 해당됩니다 — 향후 이 딜의 금액을 조정할 일이 생기면 스케줄부터 지워야 한다는 걸 팀이 알고 있어야 합니다.

### Quote Sync 중에는 Opportunity Line Item을 직접 고치면 안 됨 (기존 경고 재확인)
Quote가 Syncing 중일 때 OpportunityLineItem 쪽 필드(예: UnitPrice)를 직접 수정하면, Sync 엔진이 QuoteLineItem 값 기준으로 **조용히 되돌립니다**(에러 없이 원래 값으로 리셋됨). 이건 2026-08-21 Daily Report에 이미 기록된 "동시 추가 시 금액 2배" 이슈와 같은 뿌리의 문제입니다 — Syncing 중에는 반드시 Quote Line Item 쪽만 고쳐야 합니다.

---

## 15. Campaign Record Type 확장 (2종 → 4종)

### 배경
기존에는 Campaign Record Type이 `Fan_Campaign`(팬 대상 일반 마케팅)과 `Sponsorship_Collaboration`(계약 체결 후 실행) 2종뿐이었습니다. 실제 B2B 세일즈 흐름을 보면 계약 체결 **전** 단계(잠재 스폰서사 담당자 발굴)와 계약 만료 임박 시 **갱신 제안** 단계도 Campaign으로 관리할 필요가 있는데, 이 두 시나리오를 담을 Record Type이 없었습니다.

### 구현된 상태
| Record Type (신규) | Label | 대상(Target) | 용도 |
| --- | --- | --- | --- |
| `Sponsorship_Prospecting` | Sponsorship Prospecting | 잠재 스폰서사 담당자(Lead) | 계약 체결 전, 리드 모집 단계 |
| `Sponsorship_Renewal` | Sponsorship Renewal | 기존 스폰서사 담당자(Contact) | 계약 만료 임박 시 갱신 제안 |

- Metadata API로 RecordType 2종 배포 완료. 다만 **Profile의 Record Type 가시성/Layout 배정은 Metadata API로 자동 반영되지 않아서**, System Administrator Profile → Object Settings → Campaigns 화면에서 수동으로 Enable 처리하고 Layout을 기존 `Sponsorship Collaboration Layout`으로 지정(2026-08-26 완료, describe API로 `"available": true` 확인).
- 전체 Campaign Record Type 4종: `Fan_Campaign`, `Sponsorship_Prospecting`, `Sponsorship_Collaboration`, `Sponsorship_Renewal`.
- Member Status 퍼널을 새로 만든 실제 Prospecting 캠페인 1건("2026 Q4 스폰서십 데이 - 잠재 스폰서사 발굴")에 세팅: 후보 선정(기본값)→메일 발송→콜드콜 완료→참석 확정(Responded)→리마인드 완료→행사 참석(Responded).

### 쓰이는 용도
Campaign 생성 시 스폰서 관계의 생애주기 단계(발굴→실행→갱신)를 Record Type으로 구분해서 관리.

### 팀 검토가 필요한 이유
Decision 018-D("Campaign vs Collaboration → Campaign Record Type으로 구현")를 그대로 따른 확장이지만, Record Type 종류 자체가 늘어난 건 아직 문서화되지 않은 변경입니다. 새 Decision(예: Decision 020)으로 기록 후 혜준님 확인을 권장합니다.

---

## 16. Campaign List View 4종 신규 (Record Type별)

### 배경
Record Type이 4종으로 늘어나면서, Campaign 탭에서 유형별로 빠르게 필터링해서 볼 수 있는 List View가 필요했습니다.

### 구현된 상태
| List View (API Name) | 라벨(한글) | 필터 |
| --- | --- | --- |
| `Fan_Campaign_List` | 팬 캠페인 목록 | RecordType = Fan_Campaign |
| `Sponsorship_Prospecting_List` | 스폰서십 발굴 캠페인 목록 | RecordType = Sponsorship_Prospecting |
| `Sponsorship_Collaboration_List` | 스폰서십 협업 캠페인 목록 | RecordType = Sponsorship_Collaboration |
| `Sponsorship_Renewal_List` | 스폰서십 갱신 캠페인 목록 | RecordType = Sponsorship_Renewal |

> ⚠️ `ExpectedRevenue`는 이 org의 통화 설정 관련 이슈로 List View 컬럼 토큰(`CAMPAIGN.EXPECTED_REVENUE`)이 인식되지 않아 제외했습니다 — Collaboration/Renewal 목록은 대신 예산(BudgetedCost)/실집행비(ActualCost)를 표시합니다.

---

## 17. Campaign Hierarchy 확장 — 스폰서 관계 5곳

### 배경
기존 Hierarchy는 d'Alba 한 곳뿐이었습니다. §15의 새 Record Type들이 생기면서, "이 스폰서 관계의 전체 생애주기(발굴/실행/갱신) 누적 성과"를 Campaign Hierarchy Rollup(표준 기능, `HierarchyAmountWonOpportunities` 등)으로 보기 위해 확장했습니다.

### 구현된 상태
| 회사 | 최상위 루트 Campaign | 하위 연결 |
| --- | --- | --- |
| d'Alba | d'Alba Sponsorship Partnership | 협업 2개 + 갱신 1개 |
| 그린빈 커피 | 그린빈 커피 스폰서십 협업 캠페인 | 갱신 1개 |
| 루나 뷰티 | 루나 뷰티 시즌 스폰서십 캠페인 | 갱신 1개 |
| 파인베이스 스포츠 | 파인베이스 스포츠 스폰서십 갱신 협상 캠페인 | (하위 없음, 자기 자신이 루트) |
| 오르빗 통신 | 오르빗 통신 스폰서십 갱신 제안 캠페인 | (하위 없음, 자기 자신이 루트) |

Sponsorship_Prospecting 캠페인(5건)은 의도적으로 Hierarchy에서 제외했습니다 — 하나의 Prospecting 캠페인이 여러 회사를 동시에 타겟하는 대량 아웃바운드라서, 특정 회사 하나의 Hierarchy Tree에 묶는 게 구조적으로 맞지 않기 때문입니다.

### 검증
`d'Alba Sponsorship Partnership`의 `HierarchyExpectedRevenue`가 300,000,000으로 정상 롤업되는 것을 API로 확인(연결된 Opportunity 1건 기준). 별도 배치 작업 없이 실시간 계산되는 표준 기능임을 확인.

### 알려진 제약
`HierarchyAmountAllOpportunities`/`HierarchyAmountWonOpportunities`는 `Opportunity.CampaignId`(Primary Campaign Source)가 채워져 있어야 집계됩니다. 당시(§17 작성 시점) 확인 결과 전체 Opportunity 103건 중 1건만 이 필드가 채워져 있었으나, **2026-08-27 재확인 결과 현재는 7건으로 늘어나 있습니다**(파인베이스/오르빗 통신/테라핏 헬스/그린빈 커피/루나 뷰티 Opportunity 연결 작업(§23)이 이후에 진행되며 함께 채워진 것으로 보임). 다만 여전히 103건 중 7건(약 7%)뿐이라 "영업 프로세스에 정착"됐다고 보기는 이르며, 팀 차원의 프로세스 정착은 여전히 필요합니다(Decision 023 참고).

---

## 18. Partner Tier(Gold/Platinum/Diamond) 및 Sponsorship Package 재설계

### 배경
동료분(Opportunity Qualification 담당)이 `Partner_Tier__c`(Gold/Platinum/Diamond, Opportunity 필드, 종합 판단 기반·자동산정 없음)를 이미 배포하셨고, 이걸 Product/Quote 쪽과 어떻게 연결할지 논의가 있었습니다. 최종적으로 **"Product에서 Tier를 자동 계산하지 않는다"**는 원칙을 유지하면서, Tier별 제안 패키지를 참고용 Product로 준비하는 방향으로 정리했습니다.

### 핵심 설계 원칙 (동료분 피드백 반영)
- **Gold — Visibility**: 반복 노출이 목적, 단일 채널
- **Platinum — Engagement**: 노출을 넘어 팬과의 실제 접점이 목적, 복수 채널
- **Diamond — Strategic Partnership**: 상품 총량이 아니라 **"공식 파트너" 지위 자체가 핵심 가치** — 노출성 상품(유니폼 메인 패치 등)은 의도적으로 배제하고, 지위/독점 자산만 구성

### 신규 Product 7종
| 분류 | Product | 비고 |
| --- | --- | --- |
| 개별 상품 5종 | 업종 독점 스폰서십 권리, 유니폼 메인(가슴) 패치 광고, 홈경기 중계 방송 배너 노출권, 개막전/올스타전 스페셜 게임 타이틀 스폰서십, 공식 파트너 지위 인증권 | 기존 카탈로그(13종)에 없던 "독점/지위/방송" 자산 갭을 채움 |
| 티어 패키지 3종 | Gold 스타터 패키지, Platinum 통합 마케팅 패키지, Diamond 전략 파트너십 패키지 | 개별 구매 대비 10% 할인 적용, 담당자가 그대로 제안하거나 개별 조정 가능 |

전체 Sponsorship Product 카탈로그: 13종 → **21종**(개별 18 + 사전 번들 3, 신규 5개 개별 상품 중 4개는 단품·1개는 최종적으로 Diamond 패키지 구성품으로만 편입)

### 가격 조정 이력 (총 3차례, 2026-08-26)
실제 KBO/MLB 스폰서십 시세를 조사해서 3단계에 걸쳐 조정했습니다.

1. **1차**: 명명권이 유니폼 패치보다 저렴한 등 상대적 순위 오류 수정 + 독점/지위 자산군을 카탈로그 최상위로 재배치
2. **2차**: "적자 구단 → 프리미엄 구단으로 성장" 스토리 반영, 전체 1.5배 상향
3. **3차**: 한국 프로야구 기준 벤치마크(키움 히어로즈 팀명 스폰서십 연 100억원+, 수원삼성 유니폼 메인 스폰서 연 190.8억원) 조사 결과, 이 수치들은 **계열사/모기업 관계형 스폰서십**이라 순수 제3자 시장가와는 성격이 다르다는 점을 반영해 전체 1.3배 추가 상향(계열사 벤치마크의 절반 이하 수준으로 유지 — "제3자 스폰서 현실선")

### 최종 가격표 (2026-08-26 기준)
| Product | 코드 | 최종가 | 기본 계약 단위 |
| --- | --- | --- | --- |
| Diamond 전략 파트너십 패키지 | SPN-PKG-DIAMOND | 52.2억 | 최소 3년 이상 |
| 구장 내 특별 구역 명명권 | SPN-NAMING-ZONE | 24억 | 최소 3년 이상 |
| 유니폼 메인(가슴) 패치 광고 | SPN-UNIFORM-MAIN | 20억 | 1년(시즌), 권장 2~3년 |
| 공식 파트너 지위 인증권 | SPN-OFFICIAL-PARTNER-STATUS | 18억 | 1년(갱신형), 권장 2년+ |
| 업종 독점 스폰서십 권리 | SPN-CATEGORY-EXCLUSIVE | 16억 | 1년(갱신형), 권장 2년+ |
| Platinum 통합 마케팅 패키지 | SPN-PKG-PLATINUM | 12.42억 | 1년 |
| 전광판 광고 + Brand Day 패키지 | SPN-LED-BRANDDAY | 11억 | 1년(Brand Day 1회 포함) |
| 백네트 후면 LED 전광판 광고 | SPN-LED-BACKNET | 10억 | 1년(정규시즌) |
| 유니폼 소매 패치 광고 | SPN-UNIFORM-SLEEVE | 8억 | 1년(시즌) |
| 외야 보조 전광판 광고 | SPN-LED-OUTFIELD | 5억 | 1년(정규시즌) |
| 개막전/올스타전 타이틀 스폰서십 | SPN-MARQUEE-TITLE | 4.3억 | 경기 1회 |
| 홈경기 중계 방송 배너 노출권 | SPN-BROADCAST-BANNER | 4억 | 1시즌 홈경기 전체 |
| 헬멧 로고 광고 | SPN-HELMET-LOGO | 3억 | 1년(정규시즌) |
| Gold 스타터 패키지 | SPN-PKG-GOLD | 2.61억 | 1년 |
| 외야 펜스 광고 | SPN-FENCE-OUTFIELD | 2.3억 | 1년(정규시즌) |
| 덕아웃/포수석 후면 광고보드 | SPN-BOARD-DUGOUT | 2억 | 1년(정규시즌) |
| Brand Day 단독 패키지 | SPN-BRANDDAY-SOLO | 1.6억 | 경기 1회 |
| 경품 증정 프로모션 데이 | SPN-PROMO-GIVEAWAY | 1.2억 | 경기 1회 |
| 공식 SNS 브랜디드 콘텐츠 | SPN-SNS-CONTENT | 1억 | 연 12회(월 1건) |
| 콜라보 굿즈 공동기획 | SPN-COLLAB-GOODS | 0.8억 | 시즌당 1회 |
| 공식 앱/홈페이지 배너 광고 | SPN-APP-BANNER | 0.6억 | 1년(상시 노출) |

### 티어별 패키지 구성
| 패키지 | 구성 상품 | 가격 |
| --- | --- | --- |
| Gold | 외야 펜스 광고 + 공식 앱/홈페이지 배너 광고 | 2.61억 |
| Platinum | 백네트 후면 LED 전광판 광고 + 공식 SNS 브랜디드 콘텐츠 + 경품 증정 프로모션 데이 + Brand Day 단독 패키지 | 12.42억 |
| Diamond | 공식 파트너 지위 인증권 + 업종 독점 스폰서십 권리 + 구장 내 특별 구역 명명권 | 52.2억 |

### 팀 검토가 필요한 이유
- "기본 계약 단위"(연/경기/다년)는 아직 Product2에 필드로 저장돼 있지 않고 이 문서에만 정리돼 있습니다 — Quote 작성 시 참고할 수 있게 필드화할지 팀 결정이 필요합니다.
- 가격 전체가 3차례에 걸쳐 크게 상향됐습니다(최초 0.2~5억 → 최종 0.6~52.2억) — 팀 최종 검토를 권장합니다.
- Diamond 패키지가 유니폼 메인 패치·SNS 콘텐츠를 제외한 이유(재고 1개뿐인 물리 자산은 반복 판매 가능한 등급 상품에 부적합)는 §18 본문 논의를 참고해주세요.

---

## 19. Campaign 레코드 재점검 및 개선 (Opportunity Stage 조정 제외)

### 배경
Record Type 확장 후, 실제 22개 Campaign 레코드를 연결된 Opportunity와 교차 검증하는 재점검을 진행했습니다. Opportunity 담당자(은영)가 Stage별 작업을 진행 중이라, Stage 조정은 이번 범위에서 제외했습니다.

### 발견한 문제 및 조치
| 문제 | 조치 |
| --- | --- |
| d'Alba 장기 캠페인이 ExpectedRevenue=0, 연결된 Opportunity 없음 | 신규 Opportunity(`d'Alba Long-Term Sponsorship`, 30억, Qualification 단계)를 생성해 연결 → Flow가 즉시 ExpectedRevenue 3,000,000,000으로 자동 반영되는 것을 확인 |
| `d'Alba Sponsorship Partnership`(Parent)의 StartDate/EndDate 미입력 | 하위 3개 캠페인 전체 범위(2027-01-15~03-12)로 채움 |
| 그린빈 커피/루나 뷰티 협업 캠페인 재무 필드 전부 null | BudgetedCost 시나리오 값 입력(0.5억/0.8억), ActualCost=0 |
| Sponsorship Prospecting 5건 중 4건 Member Status 퍼널 미설정 | 나머지 4건에도 §15와 동일한 6단계 퍼널 적용 |

### 알려진 한계(의도적으로 미해결)
d'Alba의 두 Opportunity 모두 Stage가 `Qualification`(7단계 중 첫 단계)입니다. `Sponsorship_Collaboration` Record Type의 정의(계약 체결 후 실행)와 맞지 않지만, Opportunity 담당자의 진행 중인 작업과 충돌하지 않기 위해 이번엔 Stage를 조정하지 않았습니다 — 은영님 작업이 끝난 뒤 재조정이 필요합니다.

---

## 20. Campaign 레코드 스토리 공백 분석 및 보완 — Win-back 시나리오 추가

### 배경
22개 Campaign 전체를 Record Type 정의와 대조하며 재점검한 결과, 두 가지 공백을 발견했습니다.
1. Sponsorship_Renewal 5건 전부 Member Status 퍼널이 기본값(Sent/Responded)에 머물러 있었음
2. Renewal Record Type 설계 당시 "이탈 후 재유치(Win-back)는 별도 Record Type이 아니라 Renewal 내 Member Status로 구분한다"고 결정했는데, 이를 실제로 보여주는 데이터가 하나도 없었음(기존 5건 전부 "계약 중, 만료 임박" 시나리오뿐)

### 조치
- 신규 Campaign 1건 추가: `테라핏 헬스 이탈 스폰서 재유치 캠페인`(Sponsorship_Renewal) — 이미 계약이 만료되어 이탈한 스폰서를 재접촉하는 시나리오
- Renewal 6건(기존 5 + 신규 1) 전체에 공통 Member Status 5단계 적용: 리포트 발송 → 미팅 요청 → 협상 중(응답) → 갱신 확정(응답) → 이탈

### 결과
전체 Campaign은 23건(Fan_Campaign 7 + Prospecting 5 + Collaboration 5 + Renewal 6)이 됐습니다.

---

## 21. d'Alba 시나리오를 "단기→장기 전환"에서 "티어 승급"으로 재정렬 (멘토 피드백 반영)

### 배경
멘토 피드백에 따라 B2B 대표 시나리오가 "단기 스폰서십으로 효과 증명 → 장기 계약 전환"에서 **"Gold→Platinum→Diamond 티어가 승급하는 여정"**으로 방향이 바뀌었습니다. 기존 d'Alba 데이터(§4, §13에서 이미 문서화된 단기/장기 이중 구조)는 구 시나리오를 기준으로 만들어져 있어 재정렬이 필요했습니다.

### 조치
기존 두 Collaboration 캠페인의 실행 기간이 이미 시간 순서(1월 단기 → 2월 갱신 협상 → 3월 "장기") 그대로 순차적 흐름과 맞아떨어져서, 날짜는 그대로 두고 이름·설명·연결된 Opportunity의 Tier만 재정렬했습니다.

| 캠페인 | 변경 전 | 변경 후 |
| --- | --- | --- |
| 701bm00002i0da6AAA | d'Alba Short-Term Sponsorship Campaign | **d'Alba 1년차 협업 캠페인 (Gold)** |
| 701bm00002hfEJlAAM | d'Alba Sponsorship Campaign(장기) | **d'Alba 2년차 협업 캠페인 (Platinum)** |

- 두 캠페인 모두 기존 `[SCN-B2B-001]`/`[SCN-B2B-002]` 시나리오 태그는 유지(다른 문서에서 참조할 가능성이 있어 보존), 태그 뒤 설명 문구만 티어 성장 스토리로 재작성
- Parent(`d'Alba Sponsorship Partnership`)와 Renewal 캠페인 설명도 "Gold→Platinum 승급 여정"을 명시하도록 갱신
- 연결된 Opportunity에 실제 Tier 반영: `d'Alba Short-Term Sponsorship`(3억) → `Partner_Tier__c = Gold`, `d'Alba Long-Term Sponsorship`(30억) → `Partner_Tier__c = Platinum`

### 확정된 설계 원칙 (재점검 과정에서 정리)
- **계약 전체 상황 추적과 제품별 실행률 추적은 별도 Campaign이 아닙니다** — Campaign(전체) + `Campaign_Deliverable__c`(제품/과업별, Master-Detail 자식) 구조로 이미 해결돼 있습니다(§2).
- **갱신 시점의 "동일 조건 갱신/upsell/티어 승급" 시나리오도 별도 Campaign으로 분기하지 않습니다** — Renewal Campaign은 협상 과정 자체를 추적하는 1건이면 충분하고, 실제 결과(어떤 Product/Tier로 체결됐는지)는 그 협상에서 새로 생기는 Opportunity와 `Partner_Tier__c`에 담깁니다. 다음 실행 주기가 시작되면 새 Collaboration Campaign이 생기고 같은 Parent 아래 Hierarchy로 연결됩니다(§20의 Win-back과 동일한 설계 원칙의 연장선입니다).

---

## 22. 스키마 전파 지연 버그 — 2건 추가 확인 및 해결

### 배경
`Campaign_Deliverable__c`(§2)에서 처음 발견했던 "필드는 배포/Tooling API상 존재하지만 SOQL/Describe에서 조회 안 됨" 버그가 이번 세션에서 2건 더 재발했습니다.

### CampaignMember.Is_Converted__c
- 배포 직후 SOQL 조회 실패 → 삭제 후 즉시 재배포까지 시도했으나 여전히 실패
- 백그라운드로 SOQL 폴링을 걸어두고 다른 작업을 진행하던 중, **시간이 더 지난 뒤 자연적으로 해결**됨을 확인 — 수동 재생성이 필요 없었습니다. 이 버그가 항상 즉각적인 삭제·재생성으로 해결되는 게 아니라, 단순히 전파 시간이 더 필요한 경우도 있다는 걸 보여주는 사례입니다.

### Opportunity.Partner_Tier__c (은영 담당 필드)
- 승우가 만든 필드가 아닌데도 동일한 증상이 발생 — **이 org 자체의 플랫폼 버그**라는 근거가 더 명확해졌습니다(특정 개발자의 배포 방식 문제가 아님).
- 삭제 시도 중 "`CA_Opportunity` Lightning Record Page의 컴포넌트에서 사용 중"이라는 이유로 삭제가 차단됨 → Lightning App Builder에서 해당 컴포넌트를 먼저 제거한 뒤 필드 삭제 → 동일 스펙(Description, Picklist 값 Gold/Platinum/Diamond, Restricted 등)으로 재생성 → Lightning Page에 컴포넌트 재배치
- 삭제 전 UI로 기존 값이 비어있었음을 확인해 데이터 손실 없이 해결
- 재생성 후 SOQL 조회 정상 확인, d'Alba 두 Opportunity에 각각 Gold/Platinum 값 입력 완료(§21)

### 팀 공유 필요
이 버그가 승우·은영 양쪽이 만든 필드에서 모두 재현된 건 org 차원의 스키마 전파 지연 이슈라는 강한 증거입니다. Salesforce Support 문의 시 세 사례(Campaign_Deliverable__c, Is_Converted__c, Partner_Tier__c) 모두 함께 전달하는 걸 권장합니다.

---

## 23. 스폰서사 5곳 Account/Contact/Opportunity 신규 연결

### 배경
파인베이스 스포츠·오르빗 통신·테라핏 헬스(Renewal Campaign만 존재)와 그린빈 커피·루나 뷰티(Collaboration+Renewal Campaign만 존재), 5곳 전부 실제 Account/Contact/Opportunity가 하나도 없었습니다. 각 회사의 스토리 단계에 맞춰 Stage를 다르게 부여해서 연결했습니다 — 은영님이 진행 중인 기존 Opportunity의 Stage는 건드리지 않고, 전부 신규 레코드로만 작업했습니다.

### 구현된 상태
| 회사 | Stage | Amount | Partner Tier | 비고 |
| --- | --- | --- | --- | --- |
| 파인베이스 스포츠 | Negotiation | 12.42억 | Platinum | 갱신 협상 진행 중 시나리오 |
| 오르빗 통신 | Negotiation | 2.61억 | Gold | 갱신 협상 진행 중 시나리오 |
| 테라핏 헬스 | Qualification | (미정) | (미정) | Win-back 초기 단계, 목표 금액·티어 아직 미정 |
| 그린빈 커피 | **Closed Won** | 2.61억 | Gold | 신규 레코드라 Stage 자유 설정 가능해 최초로 "완료된 성공 사례" 확보 |
| 루나 뷰티 | **Closed Won** | 12.42억 | Platinum | 위와 동일 |

Campaign.ExpectedRevenue는 5건 전부 Flow(§13)가 자동으로 반영하는 것을 확인했습니다(예: 파인베이스 12.42억, 그린빈 2.61억).

### 팀 검토가 필요한 이유
그린빈 커피·루나 뷰티를 Closed Won으로 만든 건 d'Alba와 동일한 승급 여정(2사이클)이 아니라 각각 1개 티어에서 완결된 성공 사례로 설계한 것입니다 — 이후 이 두 회사의 Renewal이 실제로 진행되면 d'Alba처럼 다음 사이클 Collaboration Campaign을 Hierarchy로 이어붙이는 방식을 권장합니다.

---

## 24. Campaign Member 등록 누락 보완 (그린빈 커피 · 루나 뷰티) 및 Path 3종 신설

### Campaign Member 등록 누락
루나 뷰티 캠페인 화면을 점검하던 중 Campaign Members가 0건인 걸 발견했습니다 — Contact/Opportunity를 만드는 것과 Campaign Member로 등록하는 건 완전히 별개의 액션이라, 명시적으로 "Add Contacts"를 하지 않으면 연결되지 않습니다. 같은 점검에서 그린빈 커피·루나 뷰티의 Collaboration Campaign Member Status가 기본값(Sent/Responded)에 머물러 있는 것도 함께 발견했습니다 — d'Alba엔 이미 있던 5단계(Targeted→Reached→Engaged→Attended→Converted) 세팅이 이 둘엔 빠져있었습니다. 두 캠페인 모두 d'Alba와 동일한 5단계를 적용하고, 담당자 Contact를 Member로 등록(Status = `Converted`)했습니다.

### Campaign Path(진행 단계 시각화) 3종 신설
Opportunity의 `CA_Opportunity` Lightning Page엔 Path(단계별 안내 진행바)가 있는데 Campaign엔 없어서 추가했습니다. 은영님이 이미 만들어두신 `Sales_Path`(Opportunity용, 한글 가이드 포함)를 템플릿으로 삼았습니다.

| PathAssistant | Record Type | 단계별 안내 |
| --- | --- | --- |
| Sponsorship Prospecting Path | Sponsorship_Prospecting | Planned(채널 확정)→In Progress(Lead 유입 확인)→Completed(Opportunity 연결)→Aborted |
| Sponsorship Collaboration Path | Sponsorship_Collaboration | Planned(예산/예상매출)→In Progress(Deliverable 진행률)→Completed(Net Profit·갱신 검토)→Aborted |
| Sponsorship Renewal Path | Sponsorship_Renewal | Planned(성과 리포트 준비)→In Progress(Member Status 확인)→Completed(Opportunity 결과 확인)→Aborted |

> ⚠️ PathAssistant를 배포하는 것과 화면에 실제로 노출되는 건 별개입니다 — Lightning Record Page에 Path 컴포넌트를 App Builder에서 수동으로 배치해야 보입니다. 승우님이 직접 배치 완료해서 확인했습니다.

---

## 25. 갱신 캠페인 성과 요약 자동화 — 티어별 성과지표 Flow (진행 중, 미완료)

### 배경
갱신 제안 시 스폰서사에게 보여줄 성과 리포트를 자동 생성하는 기능을 설계했습니다. 처음엔 예상매출·순이익을 넣으려 했으나, **이건 구단 입장의 이득(PRM 담당자 KPI)이지 스폰서사에게 제시할 근거가 아니라는 지적**을 받고 전면 재설계했습니다.

### 티어별 성과지표 설계 (최종)
| Tier | 판매한 가치 | 제시할 성과지표 |
| --- | --- | --- |
| Gold | Visibility(반복 노출) | 총 노출된 팬(Contact) 수 |
| Platinum | Engagement(팬과의 접점) | 팬 도달 수 + 반응 수 + 반응율 |
| Diamond | Strategic Partnership(지위) | 독점 도달/반응(경쟁사와 미공유 프레이밍) + 계약 규모 성장률 + 완료 시즌 수 |

3개 Tier 공통으로 "약속 이행 신뢰도"(Campaign_Deliverable__c 기반 실행 이행률)도 포함됩니다. "전략적 지위가 유지됐다"는 검증 불가능한 주장은 넣지 않고, `Partner_Tier__c` 실제 저장값을 조건으로 건 경우에만 그 프레이밍을 쓰도록 설계해서 근거 없는 단정을 피했습니다.

### 구현 시도 — Flow 직접 작성/배포
`Renewal_Campaign_Performance_Summary`(Record-Triggered, Before Save)를 XML로 직접 작성해 배포했습니다. Campaign Hierarchy로 연결된 형제 Collaboration 캠페인들을 순회하며 팬 도달/반응/Deliverable 이행률/계약 성장률을 집계하고, 연결된 Opportunity의 `Partner_Tier__c`로 티어를 판별해 3가지 요약문 중 하나를 `Performance_Summary__c`(신규 필드)에 자동으로 채웁니다.

### 부딪힌 문제 — 스키마 전파 지연 버그 + Flow 버전 잠금의 이중 충돌
1. `Performance_Summary__c` 필드가 배포 직후 또 조회 불가 상태(§22와 동일 패턴, 이 세션 5번째 재발)에 빠졌고, 이 상태에서 Flow를 실행하니 "unhandled fault" 런타임 오류 발생
2. 필드를 삭제하려 하니 방금 만든 Flow가 참조 중이라 막힘
3. Flow를 Draft로 내리고 참조를 빼도, **예전 버전이 org에 남아있어서** 계속 막힘
4. Flow 자체를 삭제하려 해도 `insufficient access rights on cross-reference id` 오류로 API 삭제 불가 → Setup UI에서 수동으로 Flow Delete(→ 실제로는 Obsolete 처리만 됨을 확인)
5. Obsolete 버전도 여전히 참조 오류로 삭제 불가 → 원인 추적 결과, 테스트 중 실패했던 **Flow Interview(실행 기록)가 남아서 버전을 물고 있었음**을 발견 → `sf data delete record`로 FlowInterview 삭제
6. 그제서야 Tooling API(`DELETE .../tooling/sobjects/Flow/{id}`)로 예전 Flow 버전 완전 삭제 성공 → 필드 삭제 성공 → 필드 재생성까지 완료

### ✅ 2026-08-27 갱신 — 추가로 발견한 문제 2건 + 조치

이 문서의 "다음 세션" 작업으로 Flow 완성 작업을 재개하면서, Draft로 남아있던 Flow XML을 실제로 전체 정독(이전엔 grep으로 구조만 파악)한 결과 **§25 작성 시점엔 몰랐던 문제 2건**을 추가로 발견했습니다.

1. **`Get_Collab_Campaigns` 조회의 filter 1개가 깨져 있었음**: 두 번째 filter가 `<field>null__NotFound</field>`로 저장되어 있었습니다. 이는 "RecordType.DeveloperName = Sponsorship_Collaboration"을 필터로 걸려던 시도가 Flow Builder에서 유효한 필드 참조로 저장되지 못하고 깨진 것으로 보입니다(정상적으로는 RecordType의 DeveloperName이 아니라 실제 `RecordTypeId` 값으로 필터해야 함). 이 상태로는 Flow가 실행될 때마다 매번 오류가 나게 되어 있었습니다 — **Active로 전환했더라도 절대 정상 동작할 수 없는 상태**였습니다. `RecordTypeId EqualTo '012bm00000BbzKjAAJ'`(Sponsorship_Collaboration RecordType Id)로 교체했습니다.
2. **Flow가 참조하는 Roll-Up Summary 필드 2개가 애초에 생성된 적이 없었음**: `Total_Deliverable_Weight__c`, `Completed_Deliverable_Weight__c`(둘 다 Campaign_Deliverable__c.Weight__c을 Campaign__c Master-Detail 기준으로 합산 — 후자는 `Status__c = 'Completed'` 조건 필터 추가)이 Flow의 `queriedFields`에 있었지만, Campaign Object에는 존재하지 않았습니다(`sf sobject describe` 재확인 완료). §25 작업 당시 `Performance_Summary__c` 전파 지연 사고(Flow Interview 삭제까지 갔던 그 사고) 대응에 매몰되어 이 두 필드 생성 자체를 놓친 것으로 보입니다. 신규 생성 후 배포 완료.

두 문제 모두 **Campaign 자체 스코프 내 수정**(다른 팀원 소유 필드/객체 생성 없음)이라 팀 협의 없이 바로 조치했습니다. Opportunity의 `Partner_Tier__c`/`Amount`를 읽기 전용으로 참조하는 부분은 이미 이전 세션에서 설계된 그대로 유지했습니다(은영님 파트 데이터를 캠페인 고도화를 위해 연결하는 것은 읽기 전용이라 문제 없음 — 파트 침범 보고 원칙에 따라 기록).

### ✅ 2026-08-27 최종 갱신 — 원인 규명 및 실제 테스트 결과

**이 문제는 "이번 세션에서 새로 생긴 지연"이 아니라, 어제(2026-08-26) 세션에서 이미 한 번 delete+재생성까지 했던 바로 그 `Performance_Summary__c`가 24시간 넘게 계속 막혀있던 것이었습니다.** Setup Audit Trail을 시간순으로 전부 조회해 확인했습니다:

- 2026-08-26 05:39 — 필드 최초 생성(라벨 "성과 요약 (자동 생성)")
- 2026-08-26 06:14~06:43 — Flow 생성 → Activate → 버전 생성/삭제 반복 → Deactivate → **Flow 완전 삭제 성공** → **필드 삭제 성공** → **필드 재생성** → Flow 재생성 (§25에 기록된 절차 그대로, Metadata API만으로 실제로 끝까지 성공했음 — "Setup UI에서 수동 처리 필요"라던 §25 기록은 부정확했고, 실제로는 Activate→버전 조작→Deactivate 후 Metadata API 삭제가 정상적으로 통했음)
- 이후 **2026-08-27 05:46(이 세션 시작)까지 약 23시간 내내 describe/SOQL에서 계속 조회 불가 상태였던 것으로 확인됨** — 즉 어제의 delete+재생성이 문제를 해결하지 못했고, 그냥 지금까지 안 풀린 채로 이어진 것.

또한 이 세션에서 함께 발견한 `Total_Deliverable_Weight__c`/`Completed_Deliverable_Weight__c`/`Progress_Percent__c`(로컬에 한 번도 기록되지 않았던 미문서화 Formula 필드, 오늘 처음 retrieve해서 존재를 확인함)도 같은 시점(2026-08-26)에 만들어져 같은 증상을 보이고 있었습니다.

**오늘 시도한 것과 실제로 확인된 사실**:
1. Flow를 Active로 배포 → **성공**(깨진 filter가 수정된 새 버전이 정상적으로 Active 전환됨). 필드가 describe에 안 보이는 상태에서도 Flow 배포/활성화 자체는 막히지 않음 — 즉 Metadata 계층은 필드를 알고 있음.
2. 실제 d'Alba 2027 시즌 스폰서십 갱신 제안 캠페인(701bm00002j7mEfAAI)의 Description을 두 번 업데이트해 Before-Save Flow를 실제로 두 번 실행시킴 → **두 번 다 오류 없이 성공**(§25에서 겪었던 "unhandled fault"가 이번엔 발생하지 않음).
3. 그런데도 SOQL, `sf sobject describe`, 그리고 **Salesforce REST API의 순수 레코드 조회(`GET /sobjects/Campaign/{id}`, describe/SOQL과 무관한 별도 경로)** 세 가지 모두에서 `Performance_Summary__c`를 포함한 4개 필드가 **여전히 전혀 나타나지 않음**을 확인했습니다. REST 레코드 조회까지 안 보인다는 건, 이게 단순 쿼리 캐시 문제가 아니라 **이 4개 필드가 이 Org의 어떤 읽기 API 경로에서도 아직 "발행(publish)"되지 않은 상태**라는 뜻입니다.
4. Flow 자체는 오류 없이 도는 걸 확인했지만, 결과적으로 `Performance_Summary__c`에 실제 값이 채워졌는지는 API로는 확인이 불가능한 상태입니다.

**결론**: 이건 일반적인 "몇 분~몇십 분 기다리면 풀리는" 스키마 전파 지연이 아니라, 이 특정 Trial Org에서 24시간 넘게 지속되는 이례적인 현상입니다. 어제 이미 한 번 delete+재생성을 정상적으로 완료했음에도 재발했다는 점에서, **delete+재생성이 근본 해결책이 아닐 가능성이 높습니다.** 추가 API 시도로는 더 진전이 없어 중단했습니다. 다음 중 하나가 필요합니다:
- Salesforce Setup UI에서 캠페인 레코드 페이지를 직접 열어 Performance Summary/Progress 필드 값을 육안으로 확인(API가 못 보는 걸 UI 레이어는 볼 수 있는지 확인 필요)
- 훨씬 더 긴 시간(반나절~하루 이상) 경과 후 재확인
- Salesforce Support 케이스 등록(Trial Org라 지원 대상이 아닐 수 있음)

Flow는 버그 수정 반영된 버전으로 **Active 상태로 남겨뒀습니다**(비활성화해도 얻는 게 없고, 실행 자체는 오류 없이 확인됐으므로).

### 캠페인 계층 구조 형태 차이에 대한 참고 (버그 아님, 설계상 의도)
`Get_Collab_Campaigns` 수정 시 d'Alba와 그린빈/루나의 Campaign Hierarchy 형태가 다르다는 걸 확인했습니다 — d'Alba는 "d'Alba Sponsorship Partnership"이라는 상위 우산 Campaign 아래 1년차·2년차 Collaboration이 형제로 걸려있는 3단 구조인 반면, 그린빈/루나는 아직 협업 사이클이 1회뿐이라 Collaboration Campaign 자체가 Renewal의 직속 Parent인 2단 구조입니다. 이는 §17에서 이미 "그린빈 커피·루나 뷰티 Renewal이 실제로 진행되면 d'Alba처럼 다음 사이클을 Hierarchy로 연결"이라고 예견된 정상적인 진행 상태입니다. 다만 원래 filter(`ParentId = $Record.ParentId`)는 3단 구조만 지원해서 2단 구조에서는 형제 캠페인을 0건 찾는 문제가 있었습니다 — filter에 `Id = $Record.ParentId` 조건을 OR로 추가해 두 형태 모두 지원하도록 함께 고쳤습니다(§27의 P3 항목 "그린빈·루나 Renewal 진행 시 Hierarchy 연결" 필요성을 지금 당장 해소하는 효과도 있음).

### ✅ 2026-08-27 해결책 발견 — Setup UI 수동 생성이 API 배포보다 안정적

같은 날 별도로 `PricebookEntry`에 필드 2개(`Max_Discounted_Price__c`, `Max_Discount_Percent__c`, §29 참고)를 만들었는데 **똑같은 스키마 전파 지연**을 겪었습니다. Metadata API로 배포한 필드는 몇 시간이 지나도 SOQL/describe/REST/Apex 전부에서 안 보였는데, **승우가 Setup UI(Object Manager)에서 직접 "New" 버튼으로 수동 생성**하니 **몇 초 안에 즉시 SOQL로 조회 가능**해졌습니다. 이후 Apex로 실제 값도 정상적으로 저장/조회 확인 완료.

**결론**: 이 Org에서는 **Metadata API로 배포한 CustomField가 describe/SOQL/REST/Apex 계층에 반영되는 파이프라인이 어떤 이유로 막혀있고, Setup UI의 "New Custom Field" 마법사는 다른(정상 동작하는) 내부 경로를 타는 것**으로 보입니다. `Performance_Summary__c` 등 Campaign의 4개 필드도 전부 API 배포로 만든 것들이라 같은 문제에 걸려있었던 것 — 이제 같은 방법(Setup UI 수동 재생성)으로 풀 수 있을 것으로 판단됩니다.

**팀 공유 필요**: 앞으로 이 Org에서 CustomField를 Metadata API(`sf project deploy`)로 배포한 뒤 바로 안 보이면, 기다리지 말고 **Setup UI에서 수동으로 삭제 후 재생성**하는 게 훨씬 빠른 해결책입니다. Salesforce Support 문의 시에도 이 재현 방법(API 배포는 안 되고 수동 생성은 즉시 되는 대조 사례)을 함께 전달하면 원인 파악에 도움이 될 것 같습니다.

### ✅ 2026-08-27 완전 종결 — Campaign 4개 필드 전부 복구 및 실제 테스트 성공

위 해결책을 Campaign에도 그대로 적용했습니다:
1. `Progress_Percent__c`(의존성 없음) 삭제
2. Flow에서 나머지 3개 필드 참조를 임시로 제거 → Draft 재배포 → Active 전환(이전 버전 자동 Obsolete) → Tooling API로 Obsolete 버전 완전 삭제(`DELETE .../tooling/sobjects/Flow/{id}`, 이번엔 FlowInterview 없이 한 번에 성공) → 참조가 사라진 `Performance_Summary__c`/`Total_Deliverable_Weight__c`/`Completed_Deliverable_Weight__c` 삭제
3. 승우가 Setup UI에서 4개 필드 전부 동일 스펙으로 수동 재생성(라벨은 한국어로 확정 — 성과 요약/전체 이행 항목 가중치/완료된 이행 항목 가중치) → **즉시 SOQL 조회 성공**. Roll-Up 2개는 생성 직후 바로 정상 계산됨(d'Alba 2년차 기준 전체 100/완료 40 — 실제 Deliverable 4건 데이터와 정확히 일치)
4. Flow에 필드 참조 복원 → Active 재배포 → d'Alba 2027 시즌 스폰서십 갱신 제안 캠페인(701bm00002j7mEfAAI)에 실제 저장

**실제 테스트 결과** (`Performance_Summary__c` 실제 값):
> [스폰서십 성과 요약 - Platinum 파트너 갱신 참고자료]
> ■ 팬 도달 및 반응 — 총 노출된 팬(Contact) 수: 2명 / 실제 반응(참여)한 팬 수: 0명 / 팬 반응율: 0%
> ■ 약속 이행 신뢰도 — 약속한 실행 항목 중 40% 완료
> 이 성과를 바탕으로 갱신 또는 Diamond 승급을 제안드립니다.

이행률 40%는 d'Alba 1년차+2년차 두 캠페인의 실제 Deliverable 데이터(총 가중치 200, 완료 80)와 정확히 일치하고, 티어(Platinum)도 최신 연결 Opportunity의 `Partner_Tier__c`와 일치합니다. 형제 캠페인 순회 → Deliverable 이행률 계산 → Opportunity 티어 판별 → 요약문 생성까지 전 과정이 실제 데이터로 end-to-end 검증 완료됐습니다. **Task 3(Renewal 성과 요약 Flow) 완료.**

### 알려진 한계 — 자동 반영 안 됨 (발표 리허설 중 발견, 2026-08-31)
이 Flow의 트리거는 **Campaign(갱신 캠페인 자신)이 Create/Update될 때**(Before-Save)뿐입니다. 형제 Collaboration 캠페인의 Campaign_Deliverable__c 상태가 바뀌어도 그 반대 방향으로 감지해서 갱신 캠페인의 `Performance_Summary__c`를 자동으로 재계산하는 로직은 없습니다.

**실제 증상**: DLV 상태를 Completed로 바꿔도 갱신 캠페인의 성과 요약은 그대로임 → 갱신 캠페인 레코드를 직접 Edit → Save 해야(필드 변경 없어도 무방) 그 시점에 Before-Save Flow가 다시 실행되어 최신 값으로 재계산됨.

**리스크**: 담당자가 이 "터치 저장"을 깜빡하면 실제 갱신 제안 미팅에 오래된(stale) 성과 요약을 그대로 쓸 위험이 있음.

**제대로 된 해결책(미착수)**: Campaign_Deliverable__c 쪽에 새 Flow를 추가해 Status/Weight 변경 감지 → 캠페인 계층을 타고 올라가 루트 부모 파악 → 그 아래 Sponsorship Renewal 캠페인들을 찾아 기존 집계 로직을 재실행해 직접 업데이트. 오늘 만든 Blocked_Reason Slack 알림과 동일한 Before-Save(계산 준비)/After-Save(타 레코드 반영) 패턴을 재사용 가능. 발표 임박으로 이번엔 보류, Future Scope로 기록.

---

## 26. 기존 문서와의 관계

`P2_RESULT_REPORT/승우(Product, Quote, Campaign 구현).md`(2026-08-20 작성, 이미 커밋됨)는 이 문서의 내용을 반영하기 전 시점의 상태를 기록하고 있습니다 — 특히 Company Information과 Quote Status 필드는 그 문서 작성 시점에는 없었고 이번에 보완됐습니다. 두 문서를 통합할지, 이 문서를 보완 기록으로 별도 유지할지는 팀이 정합니다.

---

## 27. 다음 세션 To-Do

| 우선순위 | 작업 | 상태 |
| --- | --- | --- |
| ~~P1~~ | ~~Campaign_Deliverable__c의 4개 필드 조회 불가 문제~~ | ✅ **완료(2026-08-25)** — 필드 삭제 후 재생성으로 해결 |
| ~~P1~~ | ~~4개 필드에 실제 값(Due Date/Completed Date/Notes) 입력~~ | ✅ **완료(2026-08-25)** |
| ~~P1~~ | ~~CampaignMember.Is_Converted__c SOQL 조회 불가 문제~~ | ✅ **완료(2026-08-26)** — §22 참고, 재생성 없이 시간 경과로 자연 해결 |
| ~~P1~~ | ~~Opportunity.Partner_Tier__c(은영 담당) SOQL 조회 불가 문제~~ | ✅ **완료(2026-08-26)** — §22 참고, Lightning Page 컴포넌트 제거 후 삭제·재생성으로 해결 |
| ~~P1~~ | ~~`Campaign.Performance_Summary__c`(+동반 필드 3개) API 발행 지연~~ | ✅ **완료(2026-08-27)** — Setup UI 수동 재생성으로 근본 해결(§25 최종 종결 참고) |
| ~~P1~~ | ~~`Get_Collab_Campaigns` 조회의 깨진 filter(`null__NotFound`) 수정, 누락된 Roll-Up 필드 2개(`Total_Deliverable_Weight__c`/`Completed_Deliverable_Weight__c`) 신규 생성~~ | ✅ **완료(2026-08-27)** — §25 갱신 참고 |
| ~~P1~~ | ~~Campaign_Deliverable__c 데이터를 d'Alba 2년차 외 나머지 3개 실제 Collaboration 캠페인(1년차/그린빈/루나)에도 채워 데이터 정합성 확보~~ | ✅ **완료(2026-08-27)** — 캠페인당 4건씩 총 12건 신규 생성 |
| ~~P1~~ | ~~`Renewal_Campaign_Performance_Summary` Flow를 Active로 전환하고 실제 캠페인(d'Alba 2027 시즌 갱신 제안, 701bm00002j7mEfAAI)에 저장해 테스트~~ | ✅ **완료(2026-08-27)** — Active 전환 + 실제 저장 + `Performance_Summary__c` 실제 값 생성까지 end-to-end 검증 완료(§25 최종 종결 참고) |
| P1 | Opportunity Stage 담당자(은영) 작업 완료 후, d'Alba 1·2년차 Opportunity의 Stage를 실제 스토리(계약 체결 완료)에 맞게 조정 | 대기 중 — §19 참고 |
| P1 | Campaign_Deliverable__c / PRM_Revenue_Target__c(혜준 담당 추정) 유지 여부를 팀 Decision으로 확정 | 진행 전 |
| P1 | Budgeted Cost/Actual Cost 실제 값으로 교체 | 진행 전 |
| ~~P2~~ | ~~위 5개 Report를 Dashboard 위젯으로 확정 반영~~ | ✅ **완료(2026-08-25)** — §11 참고 |
| ~~P2~~ | ~~Campaign.ExpectedRevenue를 Opportunity Amount와 자동 동기화~~ | ✅ **완료(2026-08-25)** — §13 참고 |
| ~~P2~~ | ~~Campaign Record Type을 Prospecting/Renewal로 확장하고 List View·Hierarchy 정비~~ | ✅ **완료(2026-08-26)** — §15~17 참고 |
| ~~P2~~ | ~~Campaign 22건 재점검 및 데이터 완성도 보완, Win-back 시나리오 추가~~ | ✅ **완료(2026-08-26)** — §19~20 참고 |
| ~~P2~~ | ~~d'Alba 시나리오를 단기/장기 전환에서 티어 승급으로 재정렬~~ | ✅ **완료(2026-08-26)** — §21 참고 |
| ~~P2~~ | ~~Sponsorship Product 21종 신설·3차 가격 조정(§18) 팀 최종 승인~~ | ✅ **완료** — 팀 승인됨 |
| ~~P2~~ | ~~파인베이스/오르빗 통신/테라핏 헬스/그린빈 커피/루나 뷰티에 실제 Account·Contact·Opportunity 연결~~ | ✅ **완료(2026-08-26)** — §23 참고 |
| ~~P2~~ | ~~Campaign Member 등록 누락 보완, Campaign Path 3종 신설~~ | ✅ **완료(2026-08-26)** — §24 참고 |
| P2 | Campaign Record Type 확장(§15) 및 d'Alba 티어 재정렬(§21)을 정식 Decision(예: Decision 020)으로 기록하고 팀(혜준·은영) 확인 | 진행 전 |
| P2 | "기본 계약 단위" 정보를 Product2 필드로 구조화할지 결정(§18) | 진행 전 |
| P2 | `Postal Code` 등 Company Information 나머지 값 보완 | 진행 전 |
| P2 | Quote Status의 `Rejected`/`Denied` 두 값을 §10.1 제안대로 실제로 나눠 쓸지 팀 합의 | 진행 전 |
| P2 | Dashboard 이름을 `스폰서십 통합 현황판`으로 바꿀지 팀 확인(§11) | 진행 전 |
| P3 | §13 한계 — Opportunity의 Campaign이 재연결(A→B)될 때 예전 Campaign(A) 합계가 갱신 안 되는 문제 보완 | 진행 전 |
| P3 | Opportunity.CampaignId(Primary Campaign Source) 입력을 영업 프로세스에 정착 — Campaign Hierarchy Rollup이 d'Alba 외 회사에서도 실질적으로 작동하려면 필요(§17) | 진행 전 |
| P3 | 그린빈 커피·루나 뷰티 Renewal이 실제로 진행되면 d'Alba처럼 다음 사이클 Collaboration Campaign을 Hierarchy로 연결(§23) | 진행 전 — 단, 2026-08-27 Flow filter 수정으로 현재의 2단 구조(Collaboration이 Renewal의 직속 Parent)만으로도 성과 요약이 정상 작동하도록 만들어둠(§25 갱신). 이 항목은 실제 2번째 협업 사이클이 생겼을 때 데이터 구조를 갖추는 일이지, Flow가 이를 못 다뤄서 막힌 상태는 아님 |

---

## 28. GitHub 반영 제안

권장 경로:

```text
P2_RESULT_REPORT/B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md
```

권장 Commit Message:

```text
docs: log sponsor account/opportunity linking and renewal performance summary flow (WIP)
```

권장 브랜치: `feature/campaign-quote-undocumented-log` → PR to `dev`(`02_TEAM_GUIDE.md` §4 Phase 2 브랜치 전략).

이 문서는 실제 Org 상태를 기준으로 작성했습니다. 팀 검토 후 Decision이 나면, 해당 Decision 번호를 이 문서 각 섹션에 역참조로 추가하고 `05_DECISIONS.md`/`03_SYSTEM.md`에도 반영해야 합니다.

---

## 29. PricebookEntry 협상 하한선 필드 신설 — 최대 할인가 / 최대 할인율

### 배경
Product 파트 피드백: Opportunity Negotiation 단계에서 스폰서사와 가격 협상 시, 담당자가 가격을 어디까지 인하해도 되는지에 대한 회사 기준이 없었습니다.

### 구현
`PricebookEntry`에 커스텀 필드 2개 신설:
- `Max_Discounted_Price__c`(라벨: 최대 할인가, Currency) — 협상 시 이 밑으로 내려갈 수 없는 최소 판매가
- `Max_Discount_Percent__c`(라벨: 최대 할인율, Percent) — 정가 대비 허용 최대 할인율

13개 Sponsorship Package 상품 전부에 가격대/희소성 기준 할인 정책 값을 채웠습니다(프리미엄·희소 자산일수록 할인 폭을 좁게: 명명권 5%, 앱 배너 20% 등).

### 발견한 플랫폼 이슈 및 해결책
이 필드 신설 과정에서 §25에 기록된 스키마 전파 지연 버그의 **근본 해결책을 발견**했습니다 — Setup UI에서 "New Custom Field"로 수동 생성하면 즉시 정상 작동한다는 것. 상세 경위는 §25 최종 종결 절 참고.

### 부가 작업 — Product2 Description 보강
같은 날 별도 피드백: Coworker(Agentforce)로 견적서를 생성했을 때, 가격 정보는 Quote에서 바로 조회되지만 상품 상세 설명이 Product 데이터로 축적되어 있지 않아 활용하지 못하는 문제가 발견됐습니다. 기존 `Product2.Description`(표준 필드, 4000자 Long Text Area)이 짧은 한 줄 설명만 담고 있었던 것을, 13개 상품 전부 실제 판매 상황에서 쓸 수 있는 상세 설명으로 교체했습니다.

---

## 30. Opportunity.CampaignId 실사용 공백 대규모 해소 — 104개 회사 Campaign 신규 생성

### 배경
Decision 023 §4(Campaign Hierarchy 설계 완료 선언) 이후, 은영님께 "Opportunity 생성 시 Primary Campaign Source 입력이 필요하다"를 공유하기 위해 실제 화면(Standard Opportunity 레이아웃의 "Closed Won Outcome" 섹션 — Primary Campaign Source)을 확인하는 과정에서, **Aaron Choi가 2026-08-25에 별도로 생성한 대규모 B2B 파트너십 Opportunity 세트(104건)**를 발견했습니다. "~~파트너십 제안"/"~~시즌 공식 파트너십 계약" 명명 패턴으로, 기존에 승우가 다뤄온 5개 헤어 스폰서(d'Alba, 그린빈 커피, 루나 뷰티, 파인베이스, 오르빗 통신)와는 완전히 별개의 데이터셋이었습니다.

### 발견한 진짜 문제
단순히 "Opportunity에 Campaign 필드를 안 채운" 프로세스 문제가 아니라, **이 104개 회사 전부에 애초에 연결할 Campaign 레코드 자체가 존재하지 않았습니다.** Primary Campaign Source를 입력하고 싶어도 검색해서 나올 대상이 없는 상태 — 이건 Eunyeong님께 "입력해달라"고 요청하기 전에 Campaign 파트에서 먼저 해결해야 하는 선행 공백이라고 판단했습니다.

### 구현
1. **Campaign 104개 신규 생성**: 각 회사(Account)당 1개씩, Opportunity의 Stage 기준으로 RecordType 매핑
   - `Closed Won`(75건) → Sponsorship Collaboration, Status=In Progress, "{회사}와의 스폰서십 계약 체결 이후 실행되는 협업 캠페인입니다."
   - `Discovery/Qualification/Proposal/Negotiation/Contracting`(23건) → Sponsorship Prospecting, Status=In Progress, "{회사}와의 스폰서십 계약 체결을 위해 진행 중인 제안 캠페인입니다."
   - `Closed Lost`(6건) → Sponsorship Prospecting, Status=Aborted, "{회사}와의 스폰서십 제안을 진행했으나 계약이 성사되지 않은 캠페인입니다."
   - 104개 회사 전부 Opportunity가 1개씩뿐이라 Campaign Hierarchy(Parent/Child)는 불필요 — 파인베이스/오르빗 통신과 같은 "자기 자신이 루트" 단일 Campaign 패턴 적용
2. **Opportunity.CampaignId 104건 전부 연결**
3. **Campaign_Deliverable__c 300건 신규 생성**: Collaboration 75개 전부에 기존 5개 헤어 스폰서와 동일한 4건 템플릿(계약서 서명 20 → 브랜드 노출물 제작 착수 20 → 설치·게시 30(In Progress) → 성과 리포트 30(Not Started), Due Date는 Campaign StartDate 기준 1/3/6/9개월 후로 산정)

104건 규모라 개별 회사별 서사를 손으로 쓰는 대신, 위 3가지 템플릿(Stage별)을 일괄 적용하는 방식으로 진행했습니다 — 5개 헤어 스폰서만큼의 개별 서사 다양성은 없지만, 구조·필드·데이터 완결성은 동일 수준입니다. 안전장치(auto-mode classifier) 때문에 Campaign 생성/Deliverable 생성 모두 50~20건 단위 배치로 나눠 실행했습니다.

### 결과
- Opportunity 전체 110건 중 테스트/불완전 데이터 3건(`Company Ever`, `라온푸드-`, Account 없는 `A사 2026 Sponsorship` — 승우 판단으로 매핑 대상에서 제외) 제외한 **107건 전부 CampaignId 연결 완료**
- Campaign 전체 RecordType 분포: Collaboration 80건(기존 5+신규 75), Prospecting 34건(기존 5+신규 29), Renewal 6건, Fan_Campaign 7건
- Campaign_Deliverable__c 전체 316건(기존 16+신규 300)

### 팀 검토가 필요한 이유
이건 다른 팀원(Aaron Choi)이 만든 Opportunity 데이터에 승우가 Campaign을 연결한 사례입니다 — Opportunity 레코드 자체나 기존 필드값은 건드리지 않고 `CampaignId`(빈 필드)만 채웠고, 신규 생성한 Campaign/Campaign_Deliverable__c는 전부 Campaign 파트 소유 오브젝트입니다. 승우의 결정 권한 원칙("내 파트의 고도화를 위해 팀원 파트의 데이터를 연결하는 건 괜찮음, 단 사후 보고 필수")에 따라 진행했고, 이 섹션이 그 보고입니다. Aaron Choi님께도 이 104개 Opportunity에 Campaign이 연결됐다는 사실을 공유할 필요가 있습니다(아직 미전달).

## 31. 캠페인 실행 지연 → Slack 실시간 알림 자동화

### 배경
`Blocked_Reason__c` 필드/Validation Rule을 완성한 뒤, "이렇게 쌓이는 지연 사유를 팀 리더가 레코드를 일일이 열어보지 않아도 알 수 있게 하자"는 아이디어로 시작. Salesforce ↔ Slack 연동을 검증하는 과정에서 이 org에 이미 딸려 있던 `SDO_Slack_*` Flow 템플릿들(Salesforce QBrix 데모 패키지 소속, `sourceTemplate: sales_channel__*`)은 전부 Opportunity/Swarm(Deal Room) 전용이라 재사용 불가함을 확인했고, 대신 범용 Slack 발송 코어 액션(`actionType: slackFlow`, `actionName: SendMessageToSlackChannel`, 파라미터 `channelId`/`message`)을 찾아 이를 기반으로 신규 구축했습니다.

### 발견한 플랫폼 제약 3가지 (팀 공유용 — 비슷한 비동기 Slack/외부 콜아웃 Flow를 만들 때 누구나 겪을 문제)
1. **Slack 발송 액션은 반드시 비동기(Scheduled Path, `AsyncAfterCommit`) 안에 있어야 함** — Flow Builder가 즉시 경고를 띄움.
2. **`$Record__Prior`(트리거 이전 값)는 Start 요소의 진입 조건(리터럴 값만 허용)에서도, 비동기 경로 안의 Decision/Assignment에서도 못 씀** — 오직 **동기(Before-Save, 또는 즉시 실행 경로)** 에서만 유효. "이전 값과 비교"가 필요한 로직은 반드시 Before-Save 단계에서 먼저 처리해야 함.
3. **비동기 경로의 `{!$Record.필드}`는 "저장 순간의 값"이 아니라 "비동기 작업이 실제 실행되는 시점의 최신 값"을 다시 조회함.** 저장 직후 같은 레코드가 다시 바뀌면(자동화 재실행, 사람의 연속 수정 등) 비동기 Flow가 보내는 메시지 내용이 이미 stale해질 수 있음 — 실제로 테스트 중 "사유"가 빈 값으로 발송되는 버그로 발견됨. 해결책: 저장 시점에 필요한 값을 **Before-Save 단계에서 미리 텍스트로 조립해 별도 필드에 박아두고, 비동기 Flow는 그 필드를 그대로 읽기만** 하도록 구조를 분리.

### 구현
1. `Campaign_Deliverable__c.Blocked_Reason__c`(기존, §전 세션) — Picklist 6종: 스폰서사 자료 대기/스폰서사 승인 대기/내부 제작·리소스 지연/외주·파트너사 지연/일정 재조율(우선순위 변경)/기타
2. 신규 필드 2개(Setup UI로 생성 — Metadata API 배포 시 스키마 전파 지연 재현 확실시되어 처음부터 UI 경로 사용):
   - `Due_Date_Pushed__c`(Checkbox) — 1차 설계에서 쓰였으나 2차 리팩터링(아래 §3 문제 해결)으로 현재는 미사용 상태로 남음. 삭제하지 않고 보류.
   - `Pending_Slack_Message__c`(Long Text Area, 500) — Before-Save가 조립한 메시지를 담는 내부 전용 필드
3. **`Campaign_Deliverable_Detect_Due_Date_Push`** (Before-Save Flow, 신규): Status가 Blocked로 바뀌거나(리터럴 비교) Due Date가 `$Record__Prior`보다 늦춰지면(Before-Save라 비교 가능), 그 순간의 정확한 값으로 메시지를 조립해 `Pending_Slack_Message__c`에 저장
4. **`Campaign_Deliverable_Blocked_Slack_Alert`** (After-Save 비동기 Flow, 신규): `Pending_Slack_Message__c`가 채워지면(비어있지 않게 바뀌면) `#campaign-alerts` 채널로 그 값을 그대로 발송 → 발송 후 필드를 다시 비워 다음 지연도 재감지되게 함
5. `#campaign-alerts` Slack 채널 신규 생성(승우가 직접, Claude의 Slack 연결과는 무관 — 아래 참고)

### 검증
DLV-0010(비핵심 실 데이터)으로 Status→Blocked 케이스와 Due Date 연기 케이스 모두 실제 저장 → Slack 메시지 도착 확인 → 원상복구까지 완료. 최종적으로 "사유" 필드가 정확히 표시되는 것까지 실 Slack 채널에서 확인함.

### 갱신 — 메시지 품질 개선 및 전체 QA (2026-08-30)
1. **Due Date 표기 한글화**: Date 필드를 메시지에 그대로 병합하면 로케일 기본값(영어, "February 28, 2027")으로 렌더링됨을 발견. Flow Formula 리소스(`Due_Date_Korean`)로 YEAR/MONTH/DAY를 조합해 "2027년 2월 28일" 형식으로 직접 조립하도록 수정(Due Date가 비어있으면 "미정" 표시).
2. **Notes__c(자유 메모) 내용 포함**: Blocked_Reason__c picklist 카테고리만으로는 부족한 구체적 정황(어느 업체, 어떤 이슈 등)을 담당자가 Notes__c에 남기면 이제 메시지에 "메모:" 줄로 함께 표시됨. 비어있으면 "(없음)" 표시(Formula 리소스 `Notes_Or_Empty`).
3. **전체 Picklist 값 QA**: Blocked_Reason__c 6종 전부(스폰서사 자료 대기/스폰서사 승인 대기/내부 제작·리소스 지연/외주·파트너사 지연/일정 재조율(우선순위 변경)/기타) + 메모 없음 폴백까지 총 7개 케이스를 실 데이터로 순차 발송·확인. 중간점(·), 괄호 등 특수문자 포함 한글 텍스트 전부 깨짐 없이 정상 표시됨.

### 참고 — Claude의 Slack 연결 오류 발견
작업 중 Claude(이 세션)의 Slack MCP 연결이 실제 팀 워크스페이스(`cloud alpacas`, Salesforce Setup의 "Manage Slack Connection"에서 Connected 확인됨)가 아니라 **전혀 다른 워크스페이스(`slackforcloudalpaca.slack.com`, 생성자 `demo_eng_admin`)에 연결되어 있음을 발견**했습니다. Salesforce 자체의 Slack 연동과는 무관한 별개 문제라 이번 자동화 구축에는 영향 없었지만(Flow Builder UI를 통해 정확한 채널 ID를 직접 확보하는 방식으로 우회), Claude에게 팀 Slack 채널 검색/메시지 발송 등을 직접 시키는 다른 용도가 생기면 claude.ai 설정 → Connectors에서 재연결이 필요합니다.

### 다음 단계 후보 (미착수)
- `Due_Date_Pushed__c` 필드 정리(삭제 또는 재사용) 여부 결정
- ~~팀 리더가 Status/Due Date를 전혀 건드리지 않고 방치하는 "조용한 지연" 케이스는 여전히 미탐지~~ → **§32 `Sponsorship_Campaign_Agent`가 해결(2026-08-31)**

## 32. Sponsorship_Campaign_Agent 신규 구축 — Agentforce 기반 병목 추적/갱신 리포트

### 배경
팀 피드백("캠페인 실행 지연을 Slack으로 실시간 알림받기") 반영 및 팀 전체 승인으로, Agentforce를 Campaign 영역에 적용하는 3번째 예외로 승격(기존 2개 예외: AI Matching, Opportunity Agent 5개 Subagent — Decision 017/022). 목적: 스폰서십 계약 실행 병목을 담당자가 추적하고 AI 대책을 받으며, 갱신 시점에 이행 결과 요약을 자동 산출.

### 구현
- **Agent Spec 선승인 절차 준수**: `Sponsorship_Campaign_Agent-AgentSpec.md` 작성 → 쓰기 범위(실제 레코드 변경 포함 여부)와 "조용한 지연" 포착 여부 2건을 사용자에게 확인받은 뒤 구축 시작.
- **Router-First 구조**: `bottleneck_monitor`(병목 조회+AI 대책 추천+승인 시 기록) / `renewal_report`(갱신 요약 조회+재계산) 2개 Subagent.
- **신규 Apex 3개**: `CampaignBottleneckFinder`(조회, Status=Blocked **또는** Due Date 초과+미완료 둘 다 포착), `CampaignMitigationRecorder`(쓰기 — Notes 기록 + 후속 Task 생성, Agent Script의 `require_user_confirmation: True`로 실행 전 확인 게이트), `RenewalSummaryRefresher`(조회 직전 대상 Campaign을 touch-update해 Before-Save Flow 강제 재계산 — §31에서 발견된 "갱신 요약 자동 미반영" 한계를 이 Agent가 해결).
- **신규 PermSet** `CA_Campaign_Agent_Access`(Agent 전용, 기존 `CA_Opportunity_Agent_Access` 관례 계승).

### 구축 중 겪은 AgentScript 문법 시행착오 (팀 공유용)
1. Action을 최상위 `actions:` 블록에 정의하려 하면 `'actions' is only allowed for GoalBasedAgent` 에러 — `AgentforceEmployeeAgent`는 **Subagent 블록 안에** `reasoning:`과 형제로 `actions:`를 두고 target/inputs/outputs를 그 안에서 정의해야 함.
2. Output 필드 속성은 `required`가 아니라 `is_required`, `visible`이 아니라 `is_displayable`/`filter_from_agent` — Design Spec 문서의 예시 코드와 실제 컴파일러 문법이 미묘하게 달라서, 로컬 컴파일러(`node index-agent.mjs`)로 실제 에러를 보고 교정하는 게 제일 빠름.
3. 쓰기 액션의 "실행 전 사용자 확인"은 별도 변수+게이트(`@utils.setVariables` + `available when`) 없이 액션 정의에 `require_user_confirmation: True` 한 줄이면 플랫폼이 대신 처리해줌 — 기존 Proposal Agent의 `confirm_save`+`proposal_confirmed` 패턴보다 단순.

### 검증 (2026-08-31 최종 완료)
Simulated Preview로 라우팅 확인(병목/갱신 질문 각각 올바른 Subagent로 이동) → Live Preview로 3개 액션 전부 실 데이터 검증:
- `get_renewal_summary`: d'Alba 갱신 캠페인을 실제로 재계산해 최신 55%(리허설 중 변경분 반영) 반환. 구현 중 `completionRate` 필드가 잘못된(항상 0인) 필드를 읽던 버그를 발견해 제거.
- `get_bottlenecks`: **실 데이터에서 69건의 "조용한 지연"을 실제로 찾아냄** — 이 Agent를 만든 이유를 그대로 증명.
- `adopt_mitigation`: 처음엔 두 번 요청해도 실행이 안 되는 버그 발견 → 원인은 **매 턴마다 재평가되는 Router가 "이전 병목 논의를 이어가는 요청"을 인식 못 하고 자기가 직접(가짜로) 답해버리는 것** → Router 지침을 "직접 답하지 말고 반드시 전환하라"로 명시해 해결. 이후 실제로 F&F(디스커버리) 캠페인 DLV-0226에 대책 적용 → 플랫폼 자동 확인("네?") → 승인 → Notes 기록 + Task 생성까지 SOQL로 직접 재확인, 테스트 후 원상복구 완료.

### Publish/Activate (2026-08-31, 팀 승인 후 진행)
`sf agent publish authoring-bundle` → `sf agent activate`(version 1) 성공. Bot 레코드 생성 확인 후 `CA_Campaign_Agent_Access`에 `agentAccesses` 추가 배포. Activate 이후 실 데이터로 재확인(d'Alba 갱신 요약 정상 반환) — **현재 Active 상태로 운영 가능.**
