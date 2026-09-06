# P2 B2B Org Baseline

> Fact Record — 실제 Salesforce Org(Alias: `CloudAlpacasProd`)를 2026-08-17 read-only로 조회한 결과를 기록한 문서. Source of Truth 아님(`03_SYSTEM.md`, `05_DECISIONS.md`가 여전히 SoT — `CLAUDE.md §7`). 이 문서는 화요일(2026-08-18) Technical Decision 회의에서 "이미 있는 것 위에 결정하는지, 처음부터 만드는지"를 구분하기 위한 참고 자료다.
>
> 조회 방법: `sf sobject describe`, SOQL(Tooling API 포함, 전부 SELECT), `sf org list metadata` — Org에 대한 create/update/delete/deploy는 수행하지 않았다. 로컬 `03_SYSTEM.md`/`05_DECISIONS.md`/`P2_TECHNICAL_DECISION_SHEET.md` 등 다른 MD 파일도 수정하지 않았다.
>
> 표기 규칙: **[Org 조회]** = 실제 Org에서 직접 확인한 사실. **[문서]** = `03_SYSTEM.md`/`05_DECISIONS.md`/`P2_WEEKEND_PM_WORKBOOK.md` 등에 이미 적혀 있는 내용(문서명 명시). 두 출처가 섞이지 않도록 매 항목마다 구분했다.

---

## 0. 대상 Object

Lead · Account · Contact · Opportunity · Product2 · Pricebook2 · PricebookEntry · Quote · Campaign — 9개. 모두 **[Org 조회] Org에 존재함**을 확인했다(9개 전부 `sf sobject describe` 성공).

---

## 1. Lead

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** Cloud Alpacas 전용 필드 **0개**. `External_ID__c`, `Score1~4__c`, `SDO_Sales_*`, `SDO_PRM_*`, `pi__*`(Pardot), `et4ae5__*`(Marketing Cloud) 등은 존재하지만 전부 관리형 패키지/데모 템플릿 필드로 보인다. |
| 3. Record Type | **[Org 조회]** 4개 — `Lead`(devName `SDO_Lead_Default`, available), `Lead - Deal Registration`(`SDO_Lead_DealRegistration`, available), `Lead - Partner Application`(`Lead_Partner_Application`, available), `Master`. **이름상 B2B Partner Candidate 흐름과 가장 가까운 `Lead - Partner Application`이 이미 available 상태로 존재** — Cloud Alpacas가 만든 것인지 Salesforce 표준 PRM 데모 RecordType인지는 미확인. |
| 4. Page Layout | **[Org 조회]** `Lead-Lead Layout`(표준), `Lead-SDO - Partner Lead`, `Lead-SDO - Lead Community`, `Lead-SDO - Lead`. Cloud Alpacas 전용 Layout 없음. `Lead-Lead Layout`은 표준 필드만 사용(Custom Field 없음, §2와 일치). |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`, `Fan_App_API_Access` 두 Cloud Alpacas 전용 PermSet 모두 Lead 관련 권한 **0건**. |
| 6. Flow / Automation | **[Org 조회]** Cloud Alpacas 명명 규칙의 Flow에서 Lead를 참조하는 것 **0건**. Apex Trigger는 `LogLeadChange`, `SDO_Tool_SalesforceRewind_Lead`(둘 다 Active) — 이름상 SDO 데모 유틸리티(변경 로그/데모 리셋 도구)로 추정, Cloud Alpacas 업무 로직 아님. |
| 7. B2B 관점 상태 | **Needs Configuration** |
| 8. 신규 필요 가능성 | Lead Score 필드(`Lead_Score__c`, Technical Decision Sheet 항목 E), Business Fit 판단 필드, FRM_Manager_Access/Fan_App_API_Access에 Lead 권한 추가, B2B 전용 Layout, `Lead - Partner Application` RecordType을 재사용할지/새로 만들지 결정 |

**[문서]** `03_SYSTEM.md §7.1`은 "Standard Lead 사용"을 확정으로 기록하지만, Decision 015 TBD 목록·`01_PROJECT.md §6.11`·`P2_WEEKEND_PM_WORKBOOK.md §3`는 같은 항목을 TBD로 남겨둔다(문서 간 충돌, 아래 §10 참고).

---

## 2. Account

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 (Person Account 활성화 확인됨) |
| 2. Custom Field | **[Org 조회]** Fan 관련: `Current_Segment__c`, `Engagement_Level__c`, `Fan_Value_Tier__c`, `Engagement_Score__c`, `Segment_Updated_Date__c`, `Acquisition_Channel__c`, `Favorite_Player__c`, `Email_Opt_In__c`/`SMS_Opt_In__c`/`Push_Opt_In__c`/`Kakao_Opt_In__c`, `Consent_Updated_Date__c`, `Tier__c` — **전부 존재 확인됨**. `Gender__c`(custom)는 **존재하지 않음** — 대신 표준 `PersonGender`/`PersonGenderIdentity` 필드가 이미 있음. Partner/PRM 관련(`Partner_Certification__c`, `Partner_Program_Level__c`, `Partnership_Status__c`, `SDO_Partner_*`)도 존재하지만 Salesforce 표준 PRM 데모 패키지 필드로 추정되며 Cloud Alpacas 스폰서십 의미로 설계된 것인지는 미확인. |
| 3. Record Type | **[Org 조회]** `Fan`(devName `Fan`, **available=true**) — Cloud Alpacas Fan 모델과 일치. `Partner`(devName `SDO_Account_Partner`, **available=true**) — B2B Sponsor Account 후보가 될 수 있으나 `SDO_` 접두로 보아 데모 템플릿 RecordType으로 추정, 재사용 여부 확인 필요. `Business Account`, `Person Account`, `Person Accounts`(`SDO_PersonAccounts`)는 모두 available=false. |
| 4. Page Layout | **[Org 조회]** `Account-Account Layout`, `Account-SDO - Account`, `Account-SDO - Partner Account`, `Account-SDO - Account Community`, `PersonAccount-Person Account Layout`, `PersonAccount-SDO - Person Account Layout`. Fan 필드는 `Account-Account Layout`과 `PersonAccount-Person Account Layout`에 모두 반영되어 있다. |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`(Read/Create/Edit, View All=true), `Fan_App_API_Access`(Read/Create/Edit) — 둘 다 Account 권한 보유. |
| 6. Flow / Automation | **[Org 조회]** `Welcome_Campaign_Flow`(Active), `First_Visit_Guide_Flow`(Active), `First_Ticket_Campaign_Flow_V1` — 모두 B2C Fan 관련(Phase 1). Apex Trigger: `LogAccountChange`, `SDO_Tool_SalesforceRewind_Account`(둘 다 Active, SDO 유틸리티 추정). |
| 7. B2B 관점 상태 | **Needs Configuration** (Fan/B2C 기반은 Already Available, Partner/B2B 기반은 미구성) |
| 8. 신규 필요 가능성 | `Partner`(`SDO_Account_Partner`) RecordType을 Cloud Alpacas Sponsor Account로 재사용할지 신규 RecordType을 만들지 결정, Partner 전용 필드(스폰서십 규모, 산업군 등) |

**[문서]** `03_SYSTEM.md §7.1`은 "Account RecordType=Sponsor/Partner"를 확정 방향으로 기록. 이번 Org 조회로 그 방향에 쓸 수 있는 기존 RecordType(`Partner`)이 이미 있다는 사실이 새로 확인됐다 — 단, 이 RecordType이 문서가 말하는 "Sponsor/Partner" 설계와 동일한 목적으로 만들어졌는지는 문서에 기록되어 있지 않다.

---

## 3. Contact

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** `Position__c`, `Uniform_Number__c`, `Notes__c`, `External_ID__c` — Cloud Alpacas Player Contact 용으로 추정(문서와 일치). `Gender__c`(custom)는 없음 — 표준 `Gender`/`GenderIdentity` 필드 존재. 그 외 `SDO_*`/`pi__*`/`et4ae5__*`는 데모 패키지 필드. |
| 3. Record Type | **[Org 조회]** `Player`(devName `Player`, **available=true**) — Cloud Alpacas 선수 Contact으로 추정. `Partner`(devName `SDO_Partner_Contact`, **available=false**) — B2B Partner Contact 후보이나 현재 **비활성 상태**라 그대로 쓸 수 없음. `Contact`(`SDO_Contact`, available=false). |
| 4. Page Layout | **[Org 조회]** `Contact-Contact Layout`(표준), `Contact-Player - Contact`, `Contact-SDO - Contact`, `Contact-SDO - Partner Contact`, `Contact-B2B Contact Layout`. |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`(Read only, View All=true), `Fan_App_API_Access`(Read only). |
| 6. Flow / Automation | **[Org 조회]** `Get_Verified_Customer_Information` — Cloud Alpacas 소속 여부 미확인(이름만으로는 판단 불가). Apex Trigger: `LogContactChange`, `SDO_Tool_SalesforceRewind_Contact`(Active, SDO 유틸리티 추정). |
| 7. B2B 관점 상태 | **Needs Configuration** |
| 8. 신규 필요 가능성 | `Partner`(`SDO_Partner_Contact`) RecordType 활성화 또는 재설계, Partner Contact 전용 필드, `Fan_App_API_Access`/`FRM_Manager_Access`에 Contact Edit 권한 추가(현재 Read만) |

**[문서]** `03_SYSTEM.md §7.1`은 "Contact RecordType=Partner Contact"를 확정 방향으로 기록. Org에는 이름이 같은 RecordType이 이미 존재하지만 비활성 상태라는 점은 문서에 없는 새로운 사실이다.

---

## 4. Opportunity

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** Cloud Alpacas 전용 필드 **확인되지 않음**. `SDO_Sales_*`, `DB_*`, `ED_*`, `Products__c` 등은 존재하나 모두 SDO Sales Cloud 데모 패키지 필드로 추정된다(`Products__c`는 이름이 모호해 확인 필요). |
| 3. Record Type | **[Org 조회]** `Channel (Partner)`(devName `ChannelPartner`, available=false), `Simple Opportunity`(available=false), `Master`(available=true). Cloud Alpacas 전용 RecordType 없음. |
| 4. Page Layout | **[Org 조회]** `Opportunity-Opportunity Layout`(표준 필드만), `Opportunity-SDO - Opportunity`. |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`, `Fan_App_API_Access` 모두 Opportunity 권한 **0건**. |
| 6. Flow / Automation | **[Org 조회]** Cloud Alpacas 명명 규칙 Flow 0건(`CGC_Create_Milestone_Progress_on_Opportunity_Close` 등은 SDO 데모 오브젝트 `CGC_Milestone__c` 계열로 판단, Cloud Alpacas 아님). Apex Trigger: `SDO_Tool_SalesforceRewind_Opportunity`(Active)만 존재. |
| 7. B2B 관점 상태 | **Not Found** — Object만 존재할 뿐 Cloud Alpacas B2B 요소가 전혀 없다 |
| 8. 신규 필요 가능성 | B2B 전용 RecordType, Expected Benefit(항목 F)/Target Segment(항목 G)/Segment Match(항목 H)/Recommendation Reason(항목 I) 필드 전체, Kanban Stage 값 설계, `FRM_Manager_Access` 등에 권한 추가 |

**[문서]** `03_SYSTEM.md §7.1`은 "Standard Opportunity, Kanban Stage"를 확정으로 기록. Org 조회 결과 이 방향에 대한 실제 구현은 아직 전혀 시작되지 않았다는 점이 확인된다.

---

## 5. Product2

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** `Category__c`, `Related_Player__c`, `Tier__c`, `External_ID__c` — Cloud Alpacas B2C 상품(Ticket/Membership/Goods) 용으로 문서와 일치. |
| 3. Record Type | **[Org 조회]** `Goods`, `Membership`, `Season Pass`, `Ticket`(모두 available=true), `Master`. Sponsorship Package용 RecordType 없음. |
| 4. Page Layout | **[Org 조회]** `Product2-Ticket - Product Layout`, `Product2-Membership - Product Layout`, `Product2-Goods - Product Layout`, `Product2-Season Pass - Product Layout`, `Product2-Product Layout`, `Product2-SDO - Product`. |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`(Read only), `Fan_App_API_Access`(Read only). |
| 6. Flow / Automation | **[Org 조회]** `Cancel_Item_or_Cancel_All`이 Product2를 참조 — Cloud Alpacas B2C 주문 취소 로직인지 확인 필요. Apex Trigger: `SDO_Tool_SalesforceRewind_Product2`(Active). |
| 7. B2B 관점 상태 | **Needs Configuration** (B2C 상품 구조는 Already Available, Sponsorship Package는 미비) |
| 8. 신규 필요 가능성 | Sponsorship Package RecordType 신설, 관련 PricebookEntry 연동 |

**[문서]** `03_SYSTEM.md §7.1`은 "Product2/PricebookEntry — Sponsorship Package 표현에 재사용"을 확정으로 기록하지만, `P2_WEEKEND_PM_WORKBOOK.md §3`는 같은 항목을 TBD로 표시(문서 간 충돌, §10 참고).

---

## 6. Pricebook2

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** `External_ID__c` 1개뿐 — Cloud Alpacas 커스터마이징 거의 없음. |
| 3. Record Type | **[Org 조회]** 없음(`Master`만) — Pricebook2는 표준적으로 RecordType을 세분화하지 않는 경우가 많다. |
| 4. Page Layout | **[Org 조회]** `Pricebook2-Price Book Layout`(표준 1개). |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`에는 권한 없음. `Fan_App_API_Access`(Read only). |
| 6. Flow / Automation | **[Org 조회]** Cloud Alpacas 관련 Flow 0건. Apex Trigger: `SDO_Tool_SalesforceRewind_Pricebook2`(Active, SDO 유틸리티). |
| 7. B2B 관점 상태 | **Needs Configuration** |
| 8. 신규 필요 가능성 | Sponsorship Package 전용 Pricebook 신설 여부(예: "Sponsorship Pricebook") — Product2/Quote 결정에 종속 |

---

## 7. PricebookEntry

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** `External_ID__c` 1개뿐. |
| 3. Record Type | **[Org 조회]** 없음(PricebookEntry는 RecordType을 지원하지 않는 표준 오브젝트). |
| 4. Page Layout | **[Org 조회]** `PricebookEntry-Price Book Entry`(표준 1개). |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`, `Fan_App_API_Access` 모두 권한 **0건**. |
| 6. Flow / Automation | **[Org 조회]** `Cancel_Item_or_Cancel_All`이 참조 — 성격 확인 필요. Apex Trigger 없음. |
| 7. B2B 관점 상태 | **Not Found** |
| 8. 신규 필요 가능성 | Sponsorship Package PricebookEntry 생성 규칙, 관련 권한 추가 |

---

## 8. Quote

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** **0개** — 완전히 표준 상태 그대로다. |
| 3. Record Type | **[Org 조회]** 없음(`Master`만). |
| 4. Page Layout | **[Org 조회]** `Quote-Quote Layout`(표준 1개). |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`, `Fan_App_API_Access` 모두 권한 **0건**. |
| 6. Flow / Automation | **[Org 조회]** Cloud Alpacas 관련 Flow 0건. Apex Trigger: `SDO_Tool_SalesforceRewind_Quote`(Active)만 존재. |
| 7. B2B 관점 상태 | **Not Found** |
| 8. 신규 필요 가능성 | 사용 여부 자체가 미결정(아래 §10). 사용하기로 결정되면 QuoteLineItem 연동, Layout, 권한 전체가 새로 필요하다. |

**[문서]** `03_SYSTEM.md §7.2 C`는 "Status: DRAFT — NOT FINAL"이라 명시한 반면 `P2_WEEKEND_PM_WORKBOOK.md §3-④`와 `P2_DUMMY_DATA_MASTER.md`는 "✅ 확정(Wireframe 근거)"이라 적고 있다(문서 간 충돌, §10 참고). Org에는 어느 쪽이든 아직 구현된 것이 없다.

---

## 9. Campaign

| 항목 | 내용 |
|---|---|
| 1. Org 존재 | **[Org 조회]** 존재함 |
| 2. Custom Field | **[Org 조회]** Cloud Alpacas 전용 커스텀 필드 확인되지 않음(`External_ID__c`, `SDO_Pardot_*`, `pi__*` 등은 Pardot/데모 패키지 필드). |
| 3. Record Type | **[Org 조회]** `Child Campaign`(available=false), `Parent Campaign`(available=false), `Partner-Led Campaign`(devName `Partner_Led_Campaign`, **available=false**), `Master`(available=true). **B2B용 RecordType 후보(`Partner-Led Campaign`)가 이미 존재하지만 비활성 상태.** |
| 4. Page Layout | **[Org 조회]** `Campaign-Campaign Layout`(표준), `Campaign-SDO - Parent Campaign`, `Campaign-SDO - Partner-Led Campaign`, `Campaign-SDO - Campaign Default`. |
| 5. Permission Set | **[Org 조회]** `FRM_Manager_Access`(Read/Create/Edit, View All=true), `Fan_App_API_Access`(Read only). |
| 6. Flow / Automation | **[Org 조회]** `Welcome_Campaign_Flow`, `First_Ticket_Campaign_Flow_V1` — B2C 목적. Apex Trigger: `CampaignDeleteCheck`, `SDO_Tool_SalesforceRewind_Campaign`(둘 다 Active). |
| 7. B2B 관점 상태 | **Needs Configuration** (B2C Campaign 운영은 Already Available, Collaboration 표현 방식은 미정) |
| 8. 신규 필요 가능성 | `Collaboration__c` Lookup 필드 신설(잠정 추천, 항목 D) 또는 기존 `Partner-Led Campaign` RecordType 활성화/재설계 — 항목 D 결정에 따름 |

**[문서]** `03_SYSTEM.md §7.1`은 Campaign 재사용 자체는 확정, RecordType vs Lookup 필드는 `03_SYSTEM.md §7.2 D`에서 "DRAFT — NOT FINAL"로 TBD. `P2_WEEKEND_PM_WORKBOOK.md §3-③`은 잠정적으로 Option B(Lookup)를 권장. Org에 이미 `Partner-Led Campaign` RecordType이 있다는 사실은 Option A(RecordType)를 재검토할 근거가 될 수 있다 — 단, 이 RecordType이 Cloud Alpacas가 만든 것인지 SDO 데모 템플릿인지는 미확인이므로 화요일 회의에서 함께 확인이 필요하다.

---

## 10. 문서 간 충돌 (참고용 — 이번 Org 조회로 해소되지 않음)

이전 감사(Phase 2 B2B Readiness Audit)에서 발견된 문서 충돌은 이번 Org 조회 대상이 아니며, 여전히 화요일 회의에서 해소되어야 한다. `CLAUDE.md §7` 기준으로 `03_SYSTEM.md`/`05_DECISIONS.md`가 SoT이다.

| 항목 | `03_SYSTEM.md`(SoT) | Working Document |
|---|---|---|
| Lead = Standard Lead | §7.1 "확정" | Decision 015 TBD 목록, `01_PROJECT.md §6.11`, Workbook §3 = "TBD" |
| Quote = Standard Quote+QuoteLineItem | §7.2 C "DRAFT — NOT FINAL" | Workbook §3-④, `P2_DUMMY_DATA_MASTER.md` = "✅ 확정" |
| Sponsorship Package = Product2/Pricebook | §7.1 "확정" | Workbook §3 = "TBD" |

---

## 11. Already Available

기존 Salesforce 기능 중 B2B 개발 시 **바로 활용 가능**하다고 이번 Org 조회로 확인된 것.

- Account/Campaign의 B2C Fan 인프라 — `Current_Segment__c`, `Engagement_Level__c`, `Fan_Value_Tier__c`, `Engagement_Score__c` 필드와 `Welcome_Campaign_Flow`/`First_Visit_Guide_Flow`가 이미 Org에 존재하고 Active 상태다. Fan Insight의 데이터 소스로 그대로 쓸 수 있다.
- Product2의 RecordType 기반 상품 분류 패턴(Ticket/Membership/Goods/Season Pass) — Sponsorship Package RecordType을 추가할 때 동일한 설계 패턴을 재사용할 수 있다.
- Lead의 `Lead - Partner Application` RecordType, Account의 `Partner`(`SDO_Account_Partner`) RecordType, Campaign의 `Partner-Led Campaign` RecordType — 이름상 B2B Partner 흐름에 이미 대응되는 RecordType이 세 오브젝트에 걸쳐 존재한다. "무에서 시작"이 아니라 "이미 있는 것을 검토 후 재사용/재설계할지 판단"하는 문제로 범위가 좁혀진다.
- `FRM_Manager_Access`, `Fan_App_API_Access` — Cloud Alpacas 전용 Permission Set 2개가 이미 Account/Campaign/Contact/Product2에 대한 권한 체계의 뼈대를 갖추고 있다. Lead/Opportunity/Quote/PricebookEntry로 확장만 하면 된다.
- `FanDetailController`, `Fan360Controller`, `GameDetailController`, `CampaignController`, `ReportController` — 5개 Apex Class 전부 Org에 존재하며 Active 상태(Test Class 포함)로 확인됐다.

---

## 12. Needs Configuration

Standard Object는 있지만 Cloud Alpacas B2B용 Field/Record Type/Layout/Permission 등이 **추가로 필요**한 것.

- **Lead**: Custom Field 0개, `FRM_Manager_Access`/`Fan_App_API_Access` 권한 0건 — 권한 확장과 필드 설계가 모두 필요.
- **Account**: `Partner`(`SDO_Account_Partner`) RecordType의 실사용 여부·필드 설계가 필요.
- **Contact**: `Partner`(`SDO_Partner_Contact`) RecordType이 존재하나 **비활성 상태** — 활성화 또는 재설계 필요.
- **Product2**: Sponsorship Package RecordType 신설 필요.
- **Pricebook2**: Sponsorship 전용 Pricebook 필요 여부 결정.
- **Campaign**: `Partner-Led Campaign` RecordType(비활성) 또는 `Collaboration__c` Lookup 필드 중 무엇으로 Collaboration을 표현할지 결정 및 구현.

---

## 13. Decision Required

2026-08-18 Technical Decision 회의에서 결정해야 하는 것만 정리했다. 항목 A~K는 `P2_TECHNICAL_DECISION_SHEET.md §2`의 내용을 그대로 인용했고, 이번 Org 조회로 새로 드러난 확인 필요 사항은 별도로 덧붙였다.

**[문서] Technical Decision Sheet A~K (원문 그대로, 아직 전부 미결정)**

| ID | 결정 항목 | 화요일 결정 질문 |
|---|---|---|
| A | Partner Candidate — Custom Object vs Lead 흡수 | Partner Candidate는 실제 영업 대상인가, 분석상 후보인가? |
| B | AI Matching — Rule-based vs Demo Sample Score | 실제 Matching Engine인가, 업무 흐름 증명용 Prototype인가? |
| C | Quote — Standard Quote+QuoteLineItem 사용 여부 | 제안서를 PDF로 이력 관리할 필요가 실제로 있는가? |
| D | Campaign vs Collaboration — RecordType vs Lookup 필드 | 지금 B2C/B2B Campaign을 화면에서 분리할 만큼 수가 많은가? |
| E | Lead Score — 표준 Rating 재사용 vs 신규 필드 | Lead Score를 숫자로 계산/표시할 것인가? |
| F | Expected Benefit — 필드 3개 vs Long Text 1개 | 기대 효과를 항상 3단계로 구분 관리할 것인가? |
| G | Target Segment — Picklist vs 자유 입력 | Target Segment를 몇 가지로 미리 정할 수 있는가? |
| H | Segment Match — 수동 입력 vs 자동 계산 | Segment Match를 지금 규칙으로 계산 가능한가? |
| I | Recommendation Reason — 자동 생성 vs 수동 입력 | AI Matching(B) 결정과 세트 |
| J | Fan Insight 화면 — Report/Dashboard vs Custom LWC | Demo에 Wireframe과 같은 화면이 꼭 필요한가? |
| K | Account 집계 필드 — Roll-up Summary vs Report/Dashboard | 이 숫자를 Account 화면에 실시간 필드로 꼭 보여줘야 하는가? |

**이번 Org 조회로 새로 추가된 확인 필요 사항 (A~K에는 없던 것)**

1. Lead의 `Lead - Partner Application`, Account의 `Partner`(`SDO_Account_Partner`), Contact의 `Partner`(`SDO_Partner_Contact`), Campaign의 `Partner-Led Campaign` — 이 4개 RecordType이 **Cloud Alpacas가 만든 것인지, Salesforce 표준 PRM/Channel Sales 데모 템플릿의 잔재인지** 확인이 필요하다. 전자라면 화요일 회의에서 바로 재사용을 논의할 수 있고, 후자라면 이름만 비슷할 뿐 Cloud Alpacas B2B 설계와 무관할 수 있다.
2. Account/Opportunity의 `Partner_Certification__c`, `Partner_Program_Level__c`, `Partnership_Status__c`(및 `SDO_Partner_*` 계열) 필드가 위와 같은 이유로 재사용 후보가 될 수 있는지, 아니면 무시해야 할 데모 필드인지 확인이 필요하다.
3. `Cancel_Item_or_Cancel_All` Flow가 Product2/PricebookEntry를 참조하는데, 이것이 Cloud Alpacas B2C 주문 취소 로직인지 확인이 필요하다(B2B PricebookEntry 설계와 겹치지 않는지 검토용).
4. `Get_Verified_Customer_Information` Flow(Contact 참조)가 Cloud Alpacas 소속인지 확인 필요.

---

## 14. Not Found

Cloud Alpacas B2B 관점에서 **아무것도 없는** 것으로 확인된 항목.

- **Opportunity**: RecordType/Field/권한/Flow 전부 Cloud Alpacas 요소 없음(표준 오브젝트 상태 그대로).
- **Quote**: Custom Field 0개, 권한 0건, Flow 0건 — 완전 백지.
- **PricebookEntry**: 권한 0건, Cloud Alpacas 관련 Flow 없음.
- Partner Candidate를 표현하는 Custom Object 또는 필드 — Org 어디에도 존재하지 않음(`grep -ril partner objects/`에서 Cloud Alpacas 관련 hit 없었음, 앞선 감사 기준).
- Sponsorship/Collaboration/Performance 측정을 위한 신규 필드 전반.

---

*읽기 전용 조회 결과 기록. Org 변경 없음, 다른 MD 파일 수정 없음. 2026-08-17 작성.*

---

## 15. 2026-08-27 재검증 — Fact Record 갱신

> 아래는 2026-08-27, `Rafael Espada`(승우) 세션에서 실제 Org(alias `CloudAlpacas`, orgId `00Dbm00000tkYqDEAU`)를 재조회한 결과다. §1~14(2026-08-17 기록)는 원문 그대로 보존하고, 여기서는 **변화가 있었던 부분만** 갱신한다. 조회 방법: `sf sobject describe`, SOQL(Tooling API 및 Setup Audit Trail 포함, 전부 SELECT). **이번 세션에서 실제 create/update/deploy(필드 4개 생성 후 3개 삭제, PermSet 1개 생성/재배포)가 발생했다** — §17에 별도 기록. 이 점에서 순수 읽기 전용이었던 8/17 조회와 다르다.

### 15.1 Product2 — 확정 수준으로 진행됨

8/17 "Sponsorship Package RecordType 없음"에서 크게 진전됨.

- **[Org 조회]** `Sponsorship Package` RecordType(devName `Sponsorship_Package`) 신설, **Active**.
- **[Org 조회]** 실제 상품 **13개** 생성 완료, 전부 Active(예: 전광판 광고+Brand Day 패키지, 백네트 후면 LED 전광판, 외야 펜스 광고, 덕아웃/포수석 광고보드, 유니폼 소매 패치, 헬멧 로고, 구장 내 특별구역 명명권, 공식 SNS 브랜디드 콘텐츠, 공식 앱/배너, Brand Day 단독 패키지, 경품 증정 프로모션, 콜라보 굿즈 공동기획 등).
- **[Org 조회]** 13개 전부 **Standard Price Book에 PricebookEntry 등록 완료**, 실제 가격 반영(예: 구장 명명권 24억, LED 전광판 11억 등).
- **B2B 관점 상태**: **Confirmed/Implemented** (8/17 "Needs Configuration"에서 승격)

### 15.2 Opportunity — 8/17 "Not Found"에서 상당히 진전됨

> ⚠️ 8/17 문서는 물론, 이번 세션 초반 제가 Tooling API `FieldDefinition` 쿼리로 "Opportunity Custom Field 0개"라고 잘못 확인한 적이 있다(§18 참고). `sf sobject describe`로 재확인한 정확한 결과는 다음과 같다.

- **[Org 조회]** Cloud Alpacas B2B 커스텀 필드 **5개 확인됨**:
  - `Expected_Benefit_Short_Term__c`(TextArea 1000, `03_SYSTEM.md §7.2 F` / Decision 018-F)
  - `Expected_Benefit_Mid_Term__c`(TextArea 1000)
  - `Expected_Benefit_Long_Term__c`(TextArea 1000)
  - `Target_Segment__c`(Text 255 — Opportunity 쪽은 Picklist가 아니라 Text로 존재. 실제 데이터 있는 Opportunity 7건 확인됨, §7.2 G 방향과 일치하나 Picklist 전환 여부는 미정)
  - `Partner_Tier__c`(Picklist)
- 그 외 `SDO_*`/`DB_*`/`ED_*`/`Products__c` 등 약 35개는 8/17과 동일하게 SDO Sales Cloud 데모 패키지 필드로 추정.
- **[Org 조회, 은영(Eunyeong Doh) 작업으로 추정]** `CA Opportunity Qualification Access`라는 **별도 PermSet**에 Opportunity 관련 필드(Contract Term, Estimated Budget, Deal Note, Client Budget, Contract Start/End Date, Partner Tier, Target Start Season, 관심 방향, 추진 시기, 의사결정자 접촉 가능 여부, Sponsorship 관심도 등)의 Field-Level Security 변경 이력이 Setup Audit Trail에 다수 존재함 — 그러나 **현재 Opportunity에는 이 필드들이 실제로 존재하지 않는다**(`sf sobject describe` 기준). 생성 후 삭제됐거나, 다른 Object 소속일 가능성 — 미확인, 은영님 확인 필요.
- **B2B 관점 상태**: **Needs Configuration → 부분 Implemented**(핵심 B2B 필드 5개는 갖춰짐, Kanban Stage/권한 등은 여전히 확인 필요)

### 15.3 Quote — 변화 없음(여전히 미착수)

- **[Org 조회]** Custom Field 0개, RecordType 없음(Master만), 실제 Quote 레코드 **0건** — 8/17과 동일.
- **[Org 조회]** `FRM_Manager_Access`/`Fan_App_API_Access` 두 PermSet 모두 Quote/QuoteLineItem 권한 0건 — 동일.
- 이번 세션에서 `PRM_Manager_Access`(§15.5)에 Quote 객체 권한(Read/Create/Edit/Delete)을 새로 부여함 — **QuoteLineItem 객체 권한은 배포를 2회 시도했으나 적용되지 않음**(에러 없이 성공 응답은 오지만 실제 반영 안 됨 — 원인 미상, Setup UI에서 Quote 기능 활성화 상태 확인 필요).
- **B2B 관점 상태**: **Not Found — 여전히 완전 미착수**(권한만 이번에 마련됨, 실제 사용/자동화는 없음)

### 15.4 Lead — 8/17엔 발견 못 했던 정교한 B2B 스코어링 모델 존재 확인 ⭐️ 중요

> 8/17 문서는 "Lead Custom Field 0개"라고 기록했으나, 이번 재조회 결과 **완전히 다르다.** 8/17 이후 대규모 작업이 있었던 것으로 보인다(작업자 미상 — 혜준님 PermSet 작업 이력과 시점이 겹침, §15.5 참고).

- **[Org 조회]** Lead Custom Field **63개** 확인(`sf sobject describe` 기준). 이 중 B2B Sponsorship 관련으로 명확히 식별되는 것:
  - `Lead_Score__c`(Number) — **Decision 018-E가 이미 구현됨**
  - `Target_Segment__c`(**Picklist**) — 값: `10-30 Female`, `10-30 Male`, `40-60 Female`, `40-60 Male`, `Family`, `etc`. **Decision 018-G의 "Picklist 값 TBD" 문제가 Lead 쪽에서는 이미 실질적으로 해소돼 있음.**
  - `Segment_Match__c`(Percent) — **Decision 018-H(Agentforce Fit Score)가 이미 필드로 존재**
  - `Recommendation_Reason__c`(TextArea) — **Decision 018-I가 이미 필드로 존재**
  - 그 외 미문서화된 추가 스코어링 필드 다수: `Score_Industry__c`, `Score_Interest__c`, `Score_LeadSource__c`, `Score_Sponsorship__c`, `Final_Lead_Score__c`, `Risk_Penalty__c`, `Score_Region__c`, `Sponsorship_History__c`, `Competitor_Sponsor__c`, `Controversial_Industry__c`, `Regional_Connection__c`, `Company_Phone__c`, `Department__c` — **`03_SYSTEM.md`/`05_DECISIONS.md` 어디에도 없는 필드들**. 상당히 정교한 Lead Scoring 모델이 문서화 없이 구축된 것으로 보임.
- **B2B 관점 상태**: 8/17 "Needs Configuration" → **대부분 Implemented, 단 완전히 문서화되지 않음(Undocumented)**

### 15.5 Permission Set — `PRM_Manager_Access` 존재 확인(8/17엔 없었음, 8/18 생성)

- **[Org 조회]** `PRM_Manager_Access`(Label: PRM Manager Access) — **생성자 혜준(Hyejune Jo), 생성일 2026-08-18**. 8/17 baseline엔 `FRM_Manager_Access`/`Fan_App_API_Access` 둘뿐이었으므로 그 다음 날 신설된 것 — 8/17 문서 기준으로는 "존재하지 않음"이 맞았고, 이후 변화.
- **[Org 조회, Setup Audit Trail 기반]** 원래(8/18, 혜준 + 8/19 이후 아론(Aaron Choi) 추가 작업) 구성:
  - Leads 탭: Visible
  - Lead: Read/Create/Edit, View All Records
  - Lead Field: `Lead_Score__c`/`Target_Segment__c`/`Segment_Match__c`/`Recommendation_Reason__c` 전부 Read/Write
  - Account: Read/Create/Edit/Delete, View All Records
  - Contact: Read/Create/Edit/Delete, View All Records (최초 Read만 → 이후 아론이 전체 CRUD로 확장)
- **[Org 조회]** 배정된 User **0명** — 아직 실사용자에게 할당되지 않은 상태.
- **[Org 조회]** `Cloud Alpacas PRM`이라는 **Custom Lightning App**과 `Cloud Alpacas PRM UtilityBar` **Lightning Page**가 같은 날(8/18, 혜준) 생성됨 — PRM Manager용 워크스페이스 자체가 이미 상당 부분 구축돼 있음. **이번 세션에서 내용을 열어보지는 않음(범위 밖) — 별도 확인 필요.**
- **또 다른 발견**: `CA Opportunity Qualification Access`라는 **완전히 별개의 PermSet**(은영 Eunyeong Doh 작업)이 존재 — Opportunity/Event/Task/Interaction Intelligence/Interaction Signal 등 여러 Object에 걸친 Field-Level Security 변경 이력이 Setup Audit Trail에 다수 있음. 이번 세션에서 상세 내용은 조사하지 않음(범위 밖) — 이 프로젝트에 **문서화되지 않은 별도 B2B/AI 관련 작업 흐름이 존재하는 것으로 추정됨.**

### 15.6 Already Available (8/27 기준 갱신)

§11에 추가로:
- Product2 Sponsorship Package RecordType + 실제 상품 13개 + PricebookEntry — 완전히 사용 가능한 상태
- Lead의 B2B 스코어링 필드 세트(Lead_Score__c 등 9개+) — 문서화만 되면 바로 활용 가능
- `PRM_Manager_Access` PermSet 뼈대(Lead/Account/Contact/Opportunity/Quote) — 이번 세션 복구+확장 후 정상

---

## 16. 문서-Org 간극에 대한 총평 (2026-08-27)

`03_SYSTEM.md §7.2`가 "TBD"로 남긴 항목(E: Lead Score, G: Target Segment Picklist 값, H: Segment Match, I: Recommendation Reason) 중 상당수가 **Org에는 이미 실제 필드로 구현되어 있다.** 즉 **Org 구현이 문서보다 앞서 있는 상태**다(8/17 baseline이 "문서가 Org보다 앞서 있다"고 기록했던 것과 정반대 방향으로 상황이 바뀜).

또한 은영·혜준 두 팀원이 이번 baseline 작성자가 인지하지 못한 **병행 B2B 작업**(각자의 PermSet, Lightning App, Scoring 필드)을 이미 진행 중인 것으로 확인된다. **팀 동기화 회의에서 이 셋(승우가 만든 Product2/Quote/Opportunity 작업, 혜준의 PRM App/PermSet, 은영의 Opportunity Qualification 작업)을 한 번에 맞춰보는 것을 권장한다.**

---

## 17. 사고 기록 — `PRM_Manager_Access` 권한 일시 유실 및 복구 (2026-08-27)

같은 세션에서 `PRM_Manager_Access`가 이미 존재하는 줄 모르고 "신규 생성"으로 배포하면서, 원래 있던 Lead/Account/Contact 객체 권한·Lead 필드 권한 4개·Leads 탭 설정이 일시적으로 삭제됐다. Setup Audit Trail(`SetupAuditTrail`, Action: `PermSetEntityPermChanged`/`PermSetFlsChanged`/`PermSetTabSettingsChangedNew`)을 근거로 원상복구하고, 원래 요청받은 Opportunity/Quote 권한을 추가로 병합해 재배포했다(§15.5가 그 최종 상태). 배정된 User가 0명이라 실사용자 피해는 없었다. Custom Field 쪽에서도 동일한 이유로 Opportunity에 중복 필드 3개(`Short_Term_Benefit__c` 등)를 만들었다가 즉시 삭제한 사례가 있었다(데이터·권한 0건이라 무해하게 정리됨).

**교훈**: Org에 새 메타데이터를 만들기 전, 이름이 비슷하거나 같은 컴포넌트가 이미 있는지 **반드시 먼저 조회**할 것 — "문서에 없다"가 "Org에 없다"를 보장하지 않는다(이 baseline 문서 자체도 8/17 스냅샷일 뿐, 계속 갱신되지 않으면 같은 함정에 빠진다).

---

## 18. 조사 방법론 주의사항 (2026-08-27)

이번 세션에서 Tooling API `FieldDefinition`(`SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName='Opportunity' AND QualifiedApiName LIKE '%\_\_c'`) 쿼리가 **실제 존재하는 커스텀 필드를 반환하지 못하는 현상**이 확인됐다(방금 배포 성공한 필드조차 조회 안 됨). 원인은 특정하지 못했으나(인덱싱 지연으로 추정), **커스텀 필드 존재 여부 확인은 반드시 `sf sobject describe --sobject <Object> --json` 방식으로 할 것** — 이 baseline 문서의 8/17 원본도 이 방식(`sf sobject describe`)을 썼기 때문에 신뢰할 수 있었다. Tooling API `FieldDefinition`/`CustomField` 쿼리는 이번 세션 기준으로 **커스텀 필드 조사 용도로 신뢰하지 말 것.**
