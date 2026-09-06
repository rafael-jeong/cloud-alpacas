# AI Handoff Context — Cloud Alpacas B2B Campaign/Quote/Product 세션

> 이 문서는 팀 문서(Source of Truth)가 아니라, **다른 AI 세션이 이 작업을 이어받을 때 빠르게 맥락을 파악하도록 돕는 브리핑 문서**입니다. 상세한 업무 근거·구현 이력은 `P2_RESULT_REPORT/B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md`(같은 폴더)를 반드시 함께 참고하세요 — 이 문서는 그 안의 내용을 요약·재진술하지 않고, **거기 없는 운영/도구 관련 정보**를 보충합니다.

---

## 1. 이 프로젝트가 뭔가

**Cloud Alpacas** — 한화 이글스를 모델링한 가상 프로야구 구단. **Cellsforce**라는 팀이 Salesforce Customer 360을 구축 중.

- **Phase 1(완료)**: B2C Fan Relationship Management(FRM) — 팬 데이터, Fan 360 Dashboard 등
- **Phase 2(진행 중)**: B2C 고도화 + **B2B Sponsorship Sales Pipeline 확장** — 이 세션은 전부 여기 해당

**Source of Truth 문서 구조** (반드시 읽고 시작할 것):
- `CLAUDE.md` — 프로젝트 철학, Baby Team 원칙
- `docs/05_DECISIONS.md` — 의사결정 기록(ADR). 특히 **Decision 003**(Standard First), **Decision 018**(A~K 기술 결정 — Quote/Campaign RecordType/Lead Score 등), **Decision 019**(Sponsorship Sales/Pipeline 중심 전환, d'Alba 대표 시나리오)
- `docs/03_SYSTEM.md` — Object/Field 설계 전체(B2C §0-2, B2B §7)
- `docs/02_TEAM_GUIDE.md` §11/§17 — 팀원별 담당 영역
- `docs/members/01_SEUNGWOO.md` — 이 세션 사용자(승우)의 담당 범위

## 2. 이 세션의 사용자는 누구인가

**승우(Salesforce Builder, 별명 Rafael/Rafael Espada)** — Product/Quote/Campaign 담당. Slack 이름 "정승우(Rafael)".

## 3. 연결된 Org / Repository

| 구분 | 값 |
|---|---|
| GitHub Repo | `https://github.com/CellsOrg/CloudAlpacas` |
| 로컬 clone 위치 | `c:\Users\Administrator\Desktop\Cloud Alpacas\CloudAlpacas` |
| 이번 세션 작업 브랜치 | `feature/campaign-quote-undocumented-log` (main 기준, PR 이미 오픈됨) |
| Production Org (sf CLI alias) | `CloudAlpacas` — **이 세션의 모든 작업은 여기 직접 반영됨** (Sandbox 아님) |
| Sandbox (미사용) | `prmaidev` — CA SF 커넥터 인증 문제로 이번 세션엔 안 씀, sf CLI로는 연결 가능 |
| sfdx-project.json 패키지 경로 | `salesforce/`(⚠️ `force-app/`이 아님 — CLAUDE.md의 다이어그램과 실제가 다름) |

⚠️ **중요**: 이번 세션 작업 전부가 **Sandbox를 거치지 않고 Production에 직접** 반영됐습니다(사용자 승인 하에). 다음 세션에서 이어갈 때도 별다른 지시가 없으면 같은 방식(Production 직접)으로 진행하되, 파괴적 작업 전엔 항상 확인받을 것.

## 4. 이번 세션에서 실제로 만든 것 (요약)

전체 근거·상세 설정값은 `B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md` §1~17 참고. 여기선 목록만.

- `Campaign_Deliverable__c` 필드 4개 스키마 반영 문제 해결(삭제 후 재생성) + 실데이터 입력
- Campaign Hierarchy(Parent-Child), 재무 필드(Budgeted/Actual/Expected Revenue) 노출
- B2B Report 8개: Sponsorship Collaboration ROI(+Net Profit 수식), Pipeline by Stage, Open Package Count, Average Quote Amount, Collaboration Status, Deliverable Status, Member Funnel(+전환율 수식 작업 중)
- Dashboard `PRM Sponsorship Campaign Performance`(→ `스폰서십 통합 현황판`으로 이름 변경 제안 중) 7개 위젯 완성
- Product Schedule(Revenue Schedule) 활성화 및 검증
- Company Information(Org 발신 정보) 정비
- Product2/Quote/Campaign 필드 12개 + Campaign_Deliverable__c 4개, 총 16개 필드에 한글 Help Text 추가
- **Campaign.ExpectedRevenue ↔ Opportunity.Amount 자동 동기화 Flow 3종**(Subflow 패턴): `Recalculate_Campaign_Expected_Revenue`(계산 로직) + `Campaign_Expected_Revenue_Sync`(생성/수정) + `Campaign_Expected_Revenue_Sync_On_Delete`(삭제) — 생성/삭제 양방향 테스트 완료
- 팀원(아론) Account Layout 피드백 분석 — 계약/재무정보·독점권은 완전 공백, 제공혜택/의무는 이미 Product2+Line Item+Campaign_Deliverable__c로 커버됨을 확인, 성과지표는 Decision 005로 의도적 Future Scope

## 5. 진행 중 — 다음에 이어받을 작업

**"전환율(Conversion Rate)" Custom Summary Formula를 `Sponsorship Member Funnel` Report에 추가하는 중.**

- 목적: Targeted 대비 Converted 비율(%)을 계산해서, 스폰서십 갱신 여부 판단에 쓸 4대 지표(재무 ROI/실행 완료율/팬 전환율/계약 D-day) 중 빠진 한 조각을 채움
- 사용자가 Report Builder UI에서 직접 만드는 중(API로 Custom Summary Formula 생성 불가 — §6 참고)
- 정확한 가이드는 이 문서 맨 아래 "전환율 작업 이어받기 프롬프트" 참고

## 6. 반드시 알아야 할 도구/환경 특이사항 (반복 삽질 방지)

이번 세션에서 실제로 겪고 확인한 것들. 다음 세션에서 똑같은 삽질을 반복하지 않도록 기록.

| 증상 | 원인 / 해결 |
|---|---|
| `sf api request rest "/services/data/..."` 뭘 해도 404 | **경로 맨 앞에 슬래시(`/`)를 붙이면 무조건 실패하는 CLI 버그.** `services/data/...`처럼 슬래시 없이 호출해야 함 |
| Dashboard에 위젯 추가/생성이 API로 절대 안 됨(`JSON_PARSER_ERROR`) | Dashboard REST API(`/analytics/dashboards`)는 payload를 아무리 최소화해도 실패 확인됨(재현성 있음). **UI(Lightning App Builder)로만 가능** — 위젯 추가는 항상 사람이 직접 |
| Report에 Custom Summary Formula를 넣을 API 필드가 없음 | `reportMetadata`에 해당 키 자체가 없음(확인 완료). **Report Builder UI로만 가능** |
| Report를 그룹핑 없이(`groupingsDown: []`) "Summary"로 저장해도 Dashboard 위젯에서 "No data" | Salesforce가 그룹 없는 Summary Report를 자동으로 Tabular로 되돌림. Dashboard 위젯(특히 Metric)은 Tabular 미지원. **의미 없어도 그룹을 하나 추가**하면 진짜 Summary로 고정됨 |
| Report 결과가 0건으로 나옴(데이터는 실제로 있는데) | `scope`가 기본값 `"one"`(특정 레코드 선택 요구) 또는 `"user"`(내 것만)로 잡혀 있을 수 있음. `orgAll`/`organization`으로 명시 필요 |
| 표준 필드(Campaign.BudgetedCost 등) Label 변경 시도 시 배포 실패 | `Cannot specify label on standard field` — Label도, Translation Workbench 번역도 막혀 있는 필드가 있음(확인: BudgetedCost/ActualCost/ExpectedRevenue/Opportunity.StageName). **단, `inlineHelpText`는 배포 가능**(같은 필드에서 확인) |
| Quote Sync 중 Opportunity Line Item을 고쳤는데 값이 조용히 원상복구됨 | Quote가 Syncing 중일 때는 **Quote Line Item 쪽만** 고쳐야 함(Opportunity 쪽은 미러링 대상). 반대로 고치면 에러 없이 그냥 되돌아감 |
| Quote/Opportunity Line Item 단가 수정 시 `FIELD_INTEGRITY_EXCEPTION` | Revenue Schedule이 걸린 Line Item은 단가 변경 자체가 원천 차단됨. 스케줄부터 지워야 함 |
| CSV Bulk Import(`sf data import bulk`) 실패 — `LineEnding is invalid` | 줄바꿈이 LF면 실패. `sed -i 's/$/\r/' file.csv`로 CRLF 변환 후 재시도 |
| 새 Custom Object/Field를 만들 때 "Record Type"을 찾음 | `Campaign_Deliverable__c`처럼 Record Type이 아예 없는 오브젝트도 있음 — 미리 존재 여부 확인할 것 |

## 7. 작업 스타일 관련 (사용자 선호)

- 실제 Org를 API로 직접 조회해서 검증하는 걸 선호함(추측 금지) — 뭔가 만들면 항상 SOQL/describe로 재확인
- Field/Flow 요소를 만들 때 **Label, API Name, Description을 전부 한국어 설명과 함께 구체적으로** 요구함
- UI 작업(Dashboard, Report Builder, Flow Builder)은 스크린샷을 주고받으며 단계별로 같이 진행하는 방식을 선호함 — 한 번에 다 알려주기보다 다음 화면이 나올 때마다 안내
- 표준 기능으로 안 되는 걸 발견하면 왜 안 되는지 원인을 먼저 설명하고, 대안(Flow, Subflow 등)을 표준 우선순위대로 제안하는 걸 선호함
- 문서화에 진심 — 세션 중 만든 것들을 GitHub 문서로 계속 남기고 싶어함(`B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md`가 그 결과물)

## 8. TBD였다가 이번 세션에 사실상 해소된 것

`docs/members/01_SEUNGWOO.md`의 [P2] TBD 2건은 Org 조회로 이미 답이 나왔습니다(문서 갱신은 아직 안 됨, 팀 확인 필요):
- Sponsorship Package Product2 RecordType → `Sponsorship_Package`로 확정 사용 중
- Campaign Collaboration RecordType → 기존 `Partner_Led_Campaign`(Salesforce Demo 템플릿 산출물로 추정) 재사용 안 함, `Sponsorship_Collaboration` 신규 생성해 사용 중

---

## 전환율 작업 이어받기 프롬프트

다음 세션에서 이 작업을 이어가려면, 아래 프롬프트를 그대로 붙여넣으면 됩니다.

```
Cloud Alpacas 프로젝트(c:\Users\Administrator\Desktop\Cloud Alpacas\CloudAlpacas)를 이어서 작업할 거야.
먼저 P2_RESULT_REPORT/AI_HANDOFF_CONTEXT.md와
P2_RESULT_REPORT/B2B_CAMPAIGN_QUOTE_UNDOCUMENTED_IMPLEMENTATION.md를 읽고 맥락을 파악해줘.

지금 하려는 작업: `Sponsorship Member Funnel` Report(Salesforce Report Id는 조회해서 확인)에
"전환율" Custom Summary Formula를 추가하는 중이야.

- 목적: Targeted로 지정된 팬 중 Converted까지 도달한 비율(%)을 계산해서,
  스폰서십 계약 갱신 여부를 판단할 때 쓸 지표로 쓴다.
- 이미 안내한 설계:
  - Column Name: 전환율 / Format: Percent, 소수점 1자리
  - Formula: PREVGROUPVAL(RowCount, MEMBER_STATUS, "Converted") / PREVGROUPVAL(RowCount, MEMBER_STATUS, "Targeted") * 100
  - Display: Selected Groups → Campaign Name 레벨에만 표시
- Report Builder는 API로 Custom Summary Formula 생성이 안 돼서(AI_HANDOFF_CONTEXT.md §6 참고),
  UI에서 내가 직접 만들고 있어. 스크린샷 보여주면서 진행 상황 확인해줘.

먼저 sf CLI로 이 Report를 조회해서 현재 상태(수식이 이미 있는지, factMap에 FORMULA1이 있는지)부터
확인하고 시작해줘. Org alias는 CloudAlpacas(Production)이야.
```
