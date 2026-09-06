# P2 Technical Decision Sheet

> Working Document — 2026-08-18(화요일) 회의용이었다. **회의 완료, 아래 §2 Decision 표에
> 결과를 반영했다.** Source of Truth는 여전히 `05_DECISIONS.md`(Decision 017·018·019)와
> `03_SYSTEM.md §7`이다(하단 "Decision 반영 규칙" 참고) — 이 문서는 회의 준비/기록용
> Working Document이며, 문서 간 내용이 어긋나면 `05_DECISIONS.md`를 기준으로 판단한다.
> 근거 문서: `CLAUDE.md`, `00_STORY.md` §8/§9, `01_PROJECT.md` §2.7/§8, `03_SYSTEM.md §7`(A~K), `05_DECISIONS.md`(특히 Decision 003/005/006/009/015/016/017/018/019)
>
> ✅ **같은 날 이후 진행된 멘토링으로 Business 방향이 추가 갱신됐다**(`05_DECISIONS.md`
> Decision 019): 대표 시나리오가 Sanrio(산리오) → **d'Alba(달바)**로 바뀌었고, Phase 2의
> 중심축이 "Collaboration"에서 **"Sponsorship Sales/Pipeline"**으로 이동했다. 아래 A~K의
> **기술 선택 자체는 바뀌지 않는다** — 다만 §2 표에 남아 있는 "Hello Kitty Collaboration"
> 시나리오 표기는 역사적 회의 기록이므로 그대로 두고, 실제 최신 시나리오는
> `P2_DUMMY_DATA_MASTER.md` §3(d'Alba)을 따른다. 또한 **Agentforce Fit/Recommendation
> Score와 Lead Score는 서로 다른 개념**이라는 점이 명확해졌다(`03_SYSTEM.md §7 E` 참고) —
> 이 Sheet의 B/E/H/I 항목을 읽을 때 이 구분을 함께 참고한다.

## 0. Review Order — 회의 진행 순서

메인으로 여는 문서는 이 파일 하나다. 나머지는 필요할 때만 참고한다. **Excel이 Object Map / Relationship Map의 Source of Truth다 — 여기 MD에서 다시 설명하지 않는다.**

| # | 단계 | 여는 곳 |
|---|---|---|
| 1 | Story | `00_STORY.md` |
| 2 | Scenario | SCN-B2B-001(Hello Kitty Collaboration) — `P2_DUMMY_DATA_MASTER.md §3` |
| 3 | Excel Object Map | `🦙 CloudAlpacas - 메타데이터 기록 [B2B 확장]` 구글시트 → "Phase 2 Object Map (Dashboard)" 탭 — 전체 Object / P1 Reuse 여부 / 현재 존재 여부 / Relationship |
| 4 | Excel Member Sheets | 같은 구글시트 → `01_SARA` ~ `05_SEUNGWOO` 탭 — 각자 이미 있는 것 / 내가 만들 것 |
| 5 | 필요한 Technical Decision | 이 문서 §2(A~K) 중 **정말 협의가 필요한 것만** 빠르게 결정 |
| 6 | Dummy Data / Data Contract | `P2_DUMMY_DATA_MASTER.md`(실제 값) + `P2_DATA_CONTRACT.md`(Owner/Related Record — 결정 이후 실행 기준) |
| 7 | 작업 시작 | 각자 Excel Member Sheet 아래쪽 "내가 추가로 만들어야 할 것"부터 |

> `P2_WEEKEND_PM_WORKBOOK.md`는 주말 작업이 끝나 더 이상 이 흐름에 없다(개인 PM 기록으로 보관, 아래 §6 참고).

---

## 1. 회의 정보

| 항목 | 내용 |
|---|---|
| Meeting | Phase 2 Technical Decision Meeting |
| Date | 2026-08-18 (Tuesday) |
| Scope | Phase 2 B2B Collaboration / Sponsorship |
| Status | **✅ 완료 — K(Account 집계)만 On Hold, 나머지 A~J 전부 확정**(`05_DECISIONS.md` Decision 017·018) |
| 원칙 | Standard First(Decision 003) — Custom은 근거가 확실할 때만 |

---

## 2. Decision Table (A~K)

| ID | Decision Item | 쉽게 말하면 | Option A | Option B | 추천 | 장점 | 단점 / Risk | 화요일 결정 질문 | Decision | Reason | Owner | Follow-up Doc |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A | Partner Candidate | 아직 연락 안 한 후보 기업을 별도로 관리할지 | Custom Object `Partner_Candidate__c` | Lead로 흡수(초기 Status로 표현) | B (Standard First) | A: 점수·근거·보류 이력 분리 관리 / B: Object 안 늘어남, 표준 Convert 재사용 | A: Object 추가(Decision006과 긴장), Lead와 필드 중복, 별도 전환 자동화 필요 / B: 분석상 후보가 Lead 목록에 섞임 | Partner Candidate는 실제 영업 대상인가, 분석상 후보인가? | ☑ **Option B** | Lead로 흡수한다 — 별도 Object 없이 Lead Status를 세분화해 Candidate 단계까지 표현 | 혜준 | `05_DECISIONS.md` Decision 018-A, `03_SYSTEM.md §7 A` |
| B | AI Matching | 점수·추천근거를 실제 계산할지, 데모용으로 넣을지 | Rule-based(Flow/Formula, VIP 후보 감지 Flow와 동일 패턴) | Demo Sample Score(수동 입력) — *Option C: Agentforce는 CLAUDE.md §5 Future Scope, 이번 결정 대상 아님* | A 또는 B | A: 결과 설명 가능, MVP 구현 가능 / B: 범위 확장 없음, 나중 재설계 가능 | A: "진짜 AI"는 아님(이름과 실제 차이) / B: 자동화 아님, 실사용 단계서 재설계 필요 | 실제 Matching Engine인가, 업무 흐름 증명용 Prototype인가? | ☑ **Option C(Agentforce)** | 표 안의 A/B 추천과 다르게, Agentforce를 채택 — CLAUDE.md §5 Future Scope의 좁은 범위 예외로 승인됨 | 혜준 | `05_DECISIONS.md` Decision 017(Business Scope 승인), Decision 018-B(기술 선택), CLAUDE.md §5 |
| C | Quote | 제안서를 표준 Quote로 만들지, Opportunity 텍스트로 대체할지 | Standard Quote + QuoteLineItem | Opportunity 필드/활동으로 대체(Quote 없음) | A 쪽(단 Sponsorship Package=Product2 확정 선행) | A: PDF 생성·발송, 이력 관리, Product2 연동 / B: 설정 단순, Decision015와 최소 일치 | A: 설정 부담, Product2 확정이 선결조건 / B: 제안 이력 관리 어려움, Wireframe UI 재현 불가 | 제안서를 PDF로 이력 관리할 필요가 실제로 있는가? | ☑ **Option A** | Standard Quote(Quote+QuoteLineItem) 사용 — Sponsorship Package=Product2 선결 조건 충족됨 | 승우 | `05_DECISIONS.md` Decision 018-C, `03_SYSTEM.md §7 C` |
| D | Campaign vs Collaboration | Campaign을 RecordType으로 나눌지, 필드 하나로 구분할지 | Campaign Record Type | `Collaboration__c` Lookup/관계 필드 | B | A: List/Report 필터링, 레이아웃 분리 용이 / B: 설정 단순, 기존 B2C Campaign 안 건드림 | A: Admin 작업 추가, 기존 §3.3 결정 재확인 필요 / B: Campaign 많아지면 B2C/B2B 혼재 가능 | 지금 B2C/B2B Campaign을 화면에서 분리할 만큼 수가 많은가? | ☑ **Option A** | Campaign Record Type으로 구현 — 표의 추천(B)과 다른 방향으로 결정 | 승우 | `05_DECISIONS.md` Decision 018-D, `03_SYSTEM.md §7 D` |
| E | Lead Score | 기존 Rating을 쓸지, 숫자 필드를 새로 만들지 | 표준 `Rating` 재사용 | 신규 `Lead_Score__c`(Number) | B | A: 필드 안 늘어남 / B: 정량 점수 정확 표현, Rating 원래 목적 유지 | A: Rating은 원래 정성적 값(Hot/Warm/Cold), 정량 점수와 성격 불일치 / B: 필드 1개 추가 | Lead Score를 숫자로 계산/표시할 것인가, 단순 등급이면 충분한가? | ☑ **Option B** | 신규 `Lead_Score__c`(Number) 필드 신설 — 표준 `Rating`은 원래 목적대로 유지 | 혜준 | `05_DECISIONS.md` Decision 018-E, `03_SYSTEM.md §7 E` |
| F | Expected Benefit | 기대효과를 단기/중기/장기로 나눌지, 한 칸에 적을지 | 필드 3개(Short/Mid/Long-term) | Long Text 1개 | A 쪽 | A: Wireframe 그대로, 구조 명확 / B: 필드 최소화 | A: 필드 3개 증가, 자유텍스트라 집계 어려움 / B: 단/중/장기 구분 불가(UI 차이) | 기대 효과를 항상 3단계로 구분 관리할 것인가? | ☑ **Option A** | 개별 필드 3개(단기/중기/장기)로 분리 — 정확한 API Name은 TBD | 은영 | `05_DECISIONS.md` Decision 018-F, `03_SYSTEM.md §7 F` |
| G | Target Segment | 미리 정한 세그먼트명 중 고를지, 자유 입력할지 | Picklist(사전 정의 목록) | Text 자유 입력 / Report 결과 요약 | A로 시작(값 최소화) | A: 값 통일, 집계 용이 / B: 유연함, Picklist 관리 불필요 | A: 새 조합마다 값 목록 추가 필요 / B: 표현 방식이 사람마다 달라 집계 어려움 | Target Segment를 몇 가지로 미리 정할 수 있는가? | ☑ **Option A** | Picklist로 구현 — 실제 값 목록은 TBD | 사라, 혜준 | `05_DECISIONS.md` Decision 018-G, `03_SYSTEM.md §7 G` |
| H | Segment Match | 담당자가 %를 직접 적을지, 규칙으로 계산할지 | Number/Percent 수동 입력 | Flow/Formula 자동 계산 | B(AI Matching) 결정과 세트 | A: 바로 시작 가능 / B: 일관된 기준, VIP 감지 Flow 패턴 재사용 | A: 근거 자동 기록 안 됨, 사람마다 기준 다름 / B: 계산 규칙 사전 합의 필요(시간 소요) | Segment Match를 지금 규칙으로 계산 가능한가, 기준이 아직 없는가? | ☑ **Agentforce Matching**(A/B 아님) | §B(AI Matching)가 Agentforce로 결정되며 세트로 함께 확정 — Number/Percent 수동입력도, Flow/Formula 자동계산도 아니다 | 혜준 | `05_DECISIONS.md` Decision 018-H(§B/Decision 017과 연동), `03_SYSTEM.md §7 H` |
| I | Recommendation Reason | 추천 이유를 시스템이 자동 생성할지, 사람이 적을지 | 자동 생성 Long Text(Flow/Apex) | 수동 입력 Long Text | B(AI Matching) 결정과 세트 | A: Wireframe UI와 일치 / B: 즉시 시작, 로직 불필요 | A: 문장 생성 로직 필요(B 결정 선행) / B: 담당자별 품질 편차 | §B(AI Matching)와 동일 | ☑ **Option A** | 자동 생성 Long Text(Agentforce Matching 결과 기반) — 수동 입력 아님 | 혜준 | `05_DECISIONS.md` Decision 018-I(§B/Decision 017과 연동), `03_SYSTEM.md §7 I` |
| J | Fan Insight 화면 | 표준 Report로 볼지, Wireframe처럼 화면을 직접 만들지 | Standard Report + Report Type + Dashboard | Custom Lightning App Page / LWC | A로 검증 후 필요시 B | A: 추가 개발 없음, Decision003·009와 일치 / B: Wireframe UI 그대로 구현 | A: 탭 전환·버튼 같은 인터랙션 표현 어려움 / B: LWC 개발 필요, MVP 범위 확대 | Demo에 Wireframe과 같은 화면이 꼭 필요한가, Report로 흐름만 증명해도 되는가? | ☑ **Option A** | Standard Report + Report Type + Dashboard 유지 — 별도 Object/LWC 없음 | 사라 | `05_DECISIONS.md` Decision 018-J, `03_SYSTEM.md §7 J` |
| K | Account 집계 필드 | Account에 협업 현황을 자동 합산해서 보여줄지 | Roll-up Summary / Formula | Report/Dashboard로 대체(필드 없음) | 기술 확인 후 결정 | A: 자동 갱신, Decision012 Roll-up 패턴 재사용 / B: 필드 추가 없음 | A: Opportunity-Account가 표준 Lookup 관계라 Roll-up 제약 가능(기술 확인 필요) / B: Account 화면에서 바로 안 보임 | 이 숫자를 Account 화면에 실시간 필드로 꼭 보여줘야 하는가? | ☑ **TBD(On Hold)** | Opportunity-Account Roll-up 가능 여부 기술 확인 전까지 A/B 어느 쪽도 확정하지 않음 | 아론 | `05_DECISIONS.md` Decision 018-K, `03_SYSTEM.md §7 K` |

---

## 3. 회의에서 반드시 확인할 핵심 질문 (✅ 모두 답변됨 — 2026-08-18)

1. **(A)** Partner Candidate를 별도 Object로 만들 것인가, Lead에 흡수할 것인가?
   → **Lead에 흡수.** 별도 Object 없음.
2. **(B)** AI Matching은 Rule-based로 할 것인가, Demo Sample Score 방식으로 할 것인가?
   → **둘 다 아님. Agentforce**로 결정(CLAUDE.md §5 예외, Decision 017).
3. **(C)** Quote를 Standard Quote로 실제 사용할 것인가? (Sponsorship Package=Product2 확정이 선행되어야 함)
   → **사용한다.** 선결 조건(Product2)은 이미 §7.1에서 확정 상태였다.
4. **(D)** Collaboration은 Campaign RecordType으로 표현할 것인가, 단순 Lookup 필드로 표현할 것인가?
   → **Campaign Record Type**으로 표현. 별도 `Collaboration__c` 없음.
5. **(E)** Lead Score를 별도 Field(`Lead_Score__c`)로 만들 것인가?
   → **만든다.** 표준 `Rating`은 그대로 유지.
6. Wireframe의 `[PROPOSAL]` 표시(Partner_Candidate__c, Opportunity.Target_Segment__c/Collaboration_Type__c, Product2.Collaboration__c, Campaign.Collaboration__c 등)는 실제 Salesforce 구현 개념과 어떻게 대응하는가 — 위 A~K 결정에 따라 각각 확정/조정된다.
   → §2 표의 Follow-up Document 열 참고. `Collaboration_Type__c`처럼 A~K에 명시적으로 없던 필드는 여전히 별도 확인 필요(TBD로 남김, 임의 확정하지 않음).

**전체 결정 결과 요약**은 §2 Decision Table 및 `05_DECISIONS.md` Decision 017(Business Scope: Agentforce)·018(Technical: A~K)을 참고한다.

---

## 4. 결정 결과 작성 규칙

각 행(A~K)의 `Decision` 칸은 회의 중 아래 형식으로 직접 체크·기입한다.

- ☐ Option A / ☐ Option B / ☐ TBD
- **Decision:** (선택한 방향을 한 줄로)
- **Reason:** (왜 그렇게 결정했는지)
- **Owner:** (후속 작업 담당자)
- **Follow-up Document:** (반영할 문서 — 예: `05_DECISIONS.md`, `01_PROJECT.md`, `03_SYSTEM.md`)

회의에서 결정되지 않은 항목은 임의로 확정하지 않고 `TBD`로 유지한다.

---

## 5. Decision 반영 규칙

> 이 Sheet는 회의용 Working Document이며 Source of Truth가 아니다.
>
> ✅ 회의에서 확정된 Technical Decision은 `05_DECISIONS.md` Decision 017(Business
> Scope)·018(Technical A~K)에 공식 기록했고, `01_PROJECT.md`·`03_SYSTEM.md`·
> `04_DEMO.md`·`02_TEAM_GUIDE.md`·`docs/members/*.md`에도 반영을 완료했다.
>
> K(Account 집계)는 여전히 On Hold다 — 회의에서 결정되지 않은 항목은 임의로
> 확정하지 않고 TBD로 유지한다는 원칙을 그대로 지킨다.

**반영 순서**: `Decision Sheet → 05_DECISIONS.md → 03_SYSTEM.md → 02_TEAM_GUIDE.md / members/ → 04_DEMO.md → data/DEMO_DATA_STANDARD.md`(전체 체크리스트는 `P2_WEEKEND_PM_WORKBOOK.md §7 "집에 돌아온 후"` 참고, `01_PROJECT.md`도 필요 시 함께 반영)
