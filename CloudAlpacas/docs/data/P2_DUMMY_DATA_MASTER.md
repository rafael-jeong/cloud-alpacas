# Cloud Alpacas — P2 Dummy Data Master

> **이 문서는 실제 레코드 값을 담는 문서다.** `docs/data/DEMO_DATA_STANDARD.md`는 "어떤
> 규칙으로 데이터를 만드는가"만 정의하는 별도 문서이며, 이 문서는 그 규칙을 적용해
> 실제로 Org에 입력할 값을 담는다(`DEMO_DATA_STANDARD.md` 서두 원칙과 동일선상 — 규칙과
> 데이터를 같은 문서에 섞지 않는다).
>
> Naming Rule은 `DEMO_DATA_STANDARD.md` §6.2, Fan 분포 기준은 §6.4를 따른다.
> 기존 Fan(이루키·박서연·김도현·최민재·정하윤)과 이름이 겹치지 않는 새 30명이다.
> 기존 5명 + 이번 30명 = 총 35명 — 이 30명은 **구조/화면/Flow 검증용 소규모 QA
> 데이터**로 유지한다(삭제하지 않음). 최종 Demo 목표 규모(**최소 5,000명**,
> 2026-08-18 멘토링으로 상향 — `05_DECISIONS.md` Decision 019)와 분포 기준은
> `DEMO_DATA_STANDARD.md` §6.4를 따른다 — 이 문서(35명)는 그 목표를 향한 1차
> 소규모 데이터다. ✅ Org에는 별도로 Fan 5,024건이 이미 존재함을 확인했다
> (`DEMO_DATA_STANDARD.md` §6.4.1) — 다만 그 5,024건이 §6.4.2 분포 기준을
> 충족하는지는 별도 QA 대상이며, 이 문서의 30명 예시와 Org의 5,024건이 같은
> 레코드인지도 확인되지 않았다(아직 검증 안 함).
>
> ✅ 아래 Object 배치(Lead=Standard Lead 등)는 2026-08-18 Technical Decision
> 회의로 **확정됐다**(`05_DECISIONS.md` Decision 017·018). Campaign(§3.6)은
> Decision D — **Campaign Record Type**으로 확정, Quote(§3.7)도 **Standard
> Quote 사용**으로 확정됐다. 아래 각 섹션에 확정 내용을 반영했다.
>
> ✅ **2026-08-18 멘토링으로 대표 시나리오가 변경됐다**(`05_DECISIONS.md` Decision
> 019): 산리오/Hello Kitty Collaboration → **d'Alba(달바) Sponsorship**. §3을
> d'Alba 기준으로 갱신했다. Fan Insight(§1~2)의 계산 구조/수치는 유지하되, 대상
> 산업을 "캐릭터·라이프스타일"에서 "뷰티(Beauty)/라이프스타일"로 좁혀 d'Alba와의
> 연결 논리를 명확히 했다.

---

## 1. Fan(Person Account) 30명

**분포 요약**
- Current Segment(6종) × 5명씩 = 30명
- Engagement Level(6종) × 5명씩 = 30명
- Fan Value Tier: VIP 4명 / 우수 9명 / 일반 17명
- Gender: 남 15 / 여 15 (그중 **10~30대 여성 11명**을 SCN-B2B-001 대표 팬층으로 표시 —
  "팬층의 변화가 뚜렷하게 발견된다"는 Story를 보여주기 위해 기존 8명에서 3명
  확대했다. 모두 가상 Demo 데이터이며 실제 Org 수치가 아니다)
- 연령대: 10대 2 / 20대 9 / 30대 9 / 40대 6 / 50대+ 4

| # | 이름 | Gender__c | 연령대 | Acquisition_Channel__c | Favorite_Player__c | Current_Segment__c | Engagement_Level__c | Fan_Value_Tier__c | SCN-001 대표팬층 |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 김서준 | 남 | 30대 | SNS | 문태양 | New Fan | 가입 팬 | 일반 | |
| 2 | 이하은 | 여 | 20대 | SNS | 문태양 | Active Fan | 관심 팬 | 일반 | ✅ |
| 3 | 박지훈 | 남 | 40대 | 검색 | 강도윤 | At-Risk Fan | 활동 팬 | 우수 | |
| 4 | 최유진 | 여 | 20대 | 지인 추천 | 문태양 | Dormant Fan | 충성 팬 | 일반 | ✅ |
| 5 | 정민준 | 남 | 30대 | 오프라인 | 이서준 | Churned Fan | 멤버십 팬 | 일반 | |
| 6 | 강수아 | 여 | 30대 | SNS | 문태양 | Unreachable Fan | 핵심 팬 | VIP | ✅ |
| 7 | 조은우 | 남 | 20대 | 검색 | 박현우 | New Fan | 가입 팬 | 일반 | |
| 8 | 윤지아 | 여 | 10대 | SNS | 문태양 | Active Fan | 관심 팬 | 일반 | ✅ |
| 9 | 장현우 | 남 | 50대+ | 지인 추천 | 강도윤 | At-Risk Fan | 활동 팬 | 일반 | |
| 10 | 임소연 | 여 | 20대 | SNS | 문태양 | Dormant Fan | 충성 팬 | 우수 | ✅ |
| 11 | 한도윤 | 남 | 40대 | 오프라인 | 이서준 | Churned Fan | 멤버십 팬 | 일반 | |
| 12 | 오예린 | 여 | 30대 | SNS | 문태양 | Unreachable Fan | 핵심 팬 | 일반 | ✅ |
| 13 | 서준호 | 남 | 20대 | 검색 | 박현우 | New Fan | 가입 팬 | 우수 | |
| 14 | 신지원 | 여 | 40대 | 지인 추천 | 강도윤 | Active Fan | 관심 팬 | 일반 | |
| 15 | 권태민 | 남 | 30대 | SNS | 문태양 | At-Risk Fan | 활동 팬 | 일반 | |
| 16 | 황서현 | 여 | 10대 | SNS | 문태양 | Dormant Fan | 충성 팬 | 일반 | ✅ |
| 17 | 안준영 | 남 | 50대+ | 오프라인 | 이서준 | Churned Fan | 멤버십 팬 | 우수 | |
| 18 | 송다인 | 여 | 20대 | SNS | 문태양 | Unreachable Fan | 핵심 팬 | VIP | ✅ |
| 19 | 류경민 | 남 | 40대 | 검색 | 박현우 | New Fan | 가입 팬 | 일반 | |
| 20 | 전하율 | 여 | 30대 | 지인 추천 | 문태양 | Active Fan | 관심 팬 | 일반 | ✅ |
| 21 | 배지호 | 남 | 20대 | SNS | 문태양 | At-Risk Fan | 활동 팬 | 일반 | |
| 22 | 홍시은 | 여 | 50대+ | 오프라인 | 이서준 | Dormant Fan | 충성 팬 | 우수 | |
| 23 | 남궁찬 | 남 | 30대 | SNS | 문태양 | Churned Fan | 멤버십 팬 | 일반 | |
| 24 | 문가은 | 여 | 40대 | 검색 | 박현우 | Unreachable Fan | 핵심 팬 | 일반 | |
| 25 | 백승우 | 남 | 20대 | 지인 추천 | 강도윤 | New Fan | 가입 팬 | VIP | |
| 26 | 곽나연 | 여 | 20대 | SNS | 문태양 | Active Fan | 관심 팬 | 우수 | ✅ |
| 27 | 심유찬 | 남 | 30대 | SNS | 문태양 | At-Risk Fan | 활동 팬 | 일반 | |
| 28 | 노아름 | 여 | 30대 | 오프라인 | 문태양 | Dormant Fan | 충성 팬 | 우수 | ✅ |
| 29 | 표재원 | 남 | 50대+ | 검색 | 박현우 | Churned Fan | 멤버십 팬 | 일반 | |
| 30 | 길민서 | 여 | 20대 | SNS | 문태양 | Unreachable Fan | 핵심 팬 | VIP | |

---

## 2. SCN-B2B-001 Fan Insight — 계산 기준 (Cross-Object Consistency)

> `DEMO_DATA_STANDARD.md`가 요구하는 "Fan Activity Pattern 집계값은 원본 Order/Admission과
> 일치해야 한다"는 원칙을 Fan Insight 숫자에도 그대로 적용한다. 아래 배정을 그대로
> Order/`Engagement_Signal__c`에 입력해야 Workbook §2의 수치가 Report에서 실제로 재현된다.
>
> ⚠️ **"뷰티/라이프스타일 관심" 데이터 표현의 한계**: 현재 `Engagement_Signal__c`는
> `Signal_Type__c`(SNS Click/Video View/App Open)·`Source__c`·`Player__c`(선호
> 선수)만 가지고 있고, "뷰티/라이프스타일/F&B" 같은 관심 카테고리를 담는 전용
> 필드는 없다(`03_SYSTEM.md §2.12`). 아래 SNS 반응 데이터는 **문태양(선수) 관련
> 콘텐츠에 대한 반응**을 대표 팬층의 활동 신호로 쓰는 기존 방식을 그대로
> 유지한다 — "이 신호가 곧 뷰티 관심을 증명한다"고 주장하지 않는다. 뷰티/라이프
> 스타일 관심사를 직접 표현하는 필드/데이터 소스가 필요한지는 별도 TBD로
> 남긴다(새 필드를 임의로 만들지 않는다).

### 2.1 대표 팬 11명의 두 하위 그룹 — 가입일(`CreatedDate`) 기준

> 팬층 변화를 더 뚜렷하게 보여주기 위해, 기존 8명 대표팬층에 **전하율, 곽나연,
> 노아름 3명을 추가**해 11명으로 확대했다(§1 표에 ✅ 반영). 이 3명은 "최근 3개월
> 이내 가입"으로 재지정한다 — 원래 최근 가입자로 지정했던 비대표 남성 3명
> (김서준, 조은우, 서준호)은 최근 가입 지정에서 제외해, **최근 3개월 신규 가입자
> 총원(8명)은 그대로 유지**한다(before 시점 전체 인원이 흔들리지 않도록).

| 하위그룹 | 대상 | 가입일 |
|---|---|---|
| 기존 그룹 (3개월 이전 가입) | 이하은, 최유진, 강수아, 윤지아 | 2026-02 ~ 2026-04 |
| 신규 그룹 (최근 3개월 이내 가입) | 임소연, 오예린, 황서현, 송다인, **전하율, 곽나연, 노아름** | 2026-06 ~ 2026-08 |

비대표 19명 중 **류경민**만 최근 3개월 이내 가입으로 지정한다(성별·연령대는 대표군 아님) —
최근 가입자 총원은 대표 7명 + 비대표 1명 = 8명으로 기존과 동일하다.

**→ 10~30대 여성 비중 18% → 약 37%(목표 "35% 정도" 이상 달성) 계산**
- 3개월 전 시점 전체 인원 = 22명(현재 30명 − 최근 3개월 신규 8명), 그중 여성 10~30대 = 4명(기존 그룹, 변화 없음) → **4/22 = 18.2%("18%")**
- 현재 시점 전체 인원 = 30명, 그중 여성 10~30대 = 11명(기존 4 + 신규 7) → **11/30 = 36.7%(약 37%)**
- 기존 "18%→27%"보다 변화 폭을 더 크게(약 1.9배 → 약 2배) 조정해, "팬층의 변화가
  뚜렷하게 발견된다"는 Story를 더 명확히 뒷받침한다. **모두 가상 Demo 데이터이며
  실제 Org 집계 결과가 아니다.**

### 2.2 굿즈 구매 전환율 — 대표팬층 확대에 맞춰 재조정 (목표: 약 25%)

대표팬층이 8명→11명으로 늘어난 만큼, 기존 구매자 수(3명)를 그대로 유지하면 자연스럽게
전환율이 낮아진다 — "팬 수는 늘었지만 구매력은 낮다"는 Story와 정확히 맞아떨어진다.

| 대상 | 문태양 관련 굿즈 Order 배정 |
|---|---|
| 이하은, 최유진, 강수아 (3명, 변화 없음) | Goods Purchase Order 1건 이상, Product2 = 문태양 유니폼(홈) 또는 문태양 관련 굿즈 |
| 나머지 대표팬 8명(신규 3명 포함) | 굿즈 Order 없음 (SNS 반응만 있는 "관심 단계" 팬으로 남겨둠) |

→ 대표팬 굿즈 전환율 = 3/11 = **27.3% (약 25%, 목표 근접)** — 기존 37.5%(약 38%)보다
확연히 낮아져 "팬은 늘었지만 구매 전환은 오히려 둔화됐다"는 문제를 보여준다.

전체 평균 15% 수준은 유지한다 — 비대표 19명 중 1~2명에게만 추가로 배정한다.

| 대상 | 배정 |
|---|---|
| 비대표 19명 중 1~2명 | 문태양 관련 굿즈 Order 1건 이상 |

→ 전체 구매자 = 3(대표) + 1~2(비대표) = 4~5명 / 30명 = **13.3~16.7%(약 15%, 변화 없음)**
→ 대표팬 25%대 ÷ 전체 15% = **약 1.8배** — 이전(2.5배)보다 격차는 줄었지만, "구매력이
낮아졌다"는 문제 자체는 절대 수치(27.3%)로 더 뚜렷하게 드러난다.
→ 위 수치는 모두 가상 Demo 데이터이며 실제 Org 집계 결과가 아니다.

### 2.3 SNS 반응률 "2배 이상" — 정확히 2배로 설계

| 대상 | `Engagement_Signal__c` 건수 |
|---|---|
| 대표팬 11명(신규 3명 포함) | 각 2건씩 (Signal_Type__c = SNS Click, Source__c = Instagram, Player__c = 문태양) |
| 비대표팬 19명 | 각 1건씩 |

→ 대표팬 평균 2건 : 비대표팬 평균 1건 = **정확히 2배**

> ⚠️ **구현 상태 명확화**: 이 `Engagement_Signal__c` 레코드는 실제 SNS(Instagram
> 등) API에서 실시간으로 가져온 데이터가 아니라 **Demo용으로 직접 입력하는 Dummy
> Data**다. "Data Cloud 등 외부 소스에서 실제 SNS 반응을 실시간으로 가져온다"는
> 기능은 현재 구현되어 있지 않다 — 미구현 상태이며, 실제 연동 여부는 별도
> Technical TBD로 남긴다(`03_SYSTEM.md` §5 Future Scope, CLAUDE.md §5). 지금
> Demo에서는 "SNS 반응이 있었다"는 사실을 `Engagement_Signal__c`의 Dummy Data로만
> **표현**할 뿐, 실제 SNS 데이터를 가져오는 파이프라인이 있는 것처럼 서술하지 않는다.

---

## 3. Master Data — SCN-B2B-001: d'Alba Sponsorship

> ⚠️ "d'Alba(달바)"는 Demo 예시다(2026-08-18 멘토링으로 산리오/Hello Kitty에서
> 교체 — `05_DECISIONS.md` Decision 019). 실제 브랜드명 사용 여부·실제 계약
> 관계 유무와 무관한 **가상 시나리오**이며, 실제 브랜드명을 그대로 쓸지 가상
> 브랜드명으로 바꿀지는 팀 결정 사항이다(`DEMO_DATA_STANDARD.md` §6.2). 아래는
> 그 결정 전까지 쓸 수 있는 임시 데이터다. 모든 레코드 Description에
> `[SCN-B2B-001]`을 포함해 하나의 Scenario로 연결한다.
>
> **기업 DB(약 100개) 중 하나로서의 위치**: d'Alba는 Agentforce가 기업 DB(약
> 100개, 화장품/뷰티·F&B·자동차·핀테크·OTT 등)에서 Cloud Alpacas 팬덤과 Fit이
> 높다고 추천한 Top 10 중 대표 사례다. 아래 3.0 Recommendation은 이 "추천
> 단계"(아직 Lead 아님)를, 3.1부터는 "Outbound 대상으로 선정되어 Lead가 된
> 이후"를 나타낸다 — Agentforce의 추천과 Lead 등록은 서로 다른 단계다(§2.7,
> `03_SYSTEM.md §7 B`).

### 3.0 Agentforce Recommendation (Top 10 중 하나) — 아직 Lead 아님

| 항목 | 값 |
|---|---|
| 추천 기업명 | d'Alba(달바) |
| 산업 | 화장품/뷰티(스킨케어) |
| Fan Fit/Recommendation Score(예시) | 92 *(실제 계산 로직은 TBD — Demo 예시 값)* |
| Recommendation Reason(예시) | "10~30대 여성 팬 비중 최근 18%→37% 증가, 해당 팬층의 뷰티/SNS 반응 신호 다수 확인 — d'Alba 타겟 고객층과 Fit 높음" *(실제 문장 생성 로직은 TBD — Demo 예시 문구)* |
| 상태 | 추천 후보(Lead 아님) |

> ⚠️ 위 Score/Reason은 Agentforce가 실제로 산출한 값이 아니라 **Demo 시나리오용
> 예시**다 — `03_SYSTEM.md §7 B`가 이미 명시하듯 Agentforce의 실제 구성(프롬프트,
> 데이터 소스, 평가 기준)은 TBD다. 이 예시는 "회의 없이 어떤 값이든 보여줘야
> 하는 실제 Demo 순간"을 대비한 자리표시자(placeholder)일 뿐, 확정 로직이 아니다.

### 3.1 Lead — Outbound 대상으로 선정된 이후

| Field | 값 |
|---|---|
| Company | d'Alba(달바) |
| Last Name | 김하나 |
| Title | Marketing Partnership Manager |
| Lead Source | FRM 발굴 (Fan Insight 기반) |
| Status | Qualified |
| `Lead_Score__c`(예시) | 78 *(Agentforce Fit Score(92)와는 다른 값 — 실제 접촉·미팅 반응을 근거로 한 예시. §2.7 "Fan Fit ≠ Lead Score" 참고)* |
| Description | [SCN-B2B-001] 10~30대 여성 팬층 × 뷰티/라이프스타일 관심 신호(§2) 기반 Agentforce 추천(Fit 92) → Outbound 접촉 후 Lead 등록 |

### 3.2 Account (Lead Convert 후)

| Field | 값 |
|---|---|
| Account Name | d'Alba(달바) |
| Record Type | Partner |
| Industry | Cosmetics / Beauty |
| Description | [SCN-B2B-001] |

### 3.3 Contact

| Field | 값 |
|---|---|
| Name | 김하나 |
| Title | Marketing Partnership Manager |
| Account | d'Alba(달바) |
| Description | [SCN-B2B-001] |

### 3.4 Opportunity

| Field | 값 |
|---|---|
| Opportunity Name | d'Alba × Cloud Alpacas — Advertising Sponsorship |
| Account | d'Alba(달바) |
| Stage | Proposal/Price Quote |
| Amount | 50,000,000원 |
| Close Date | 2027-03-01 |
| Description | [SCN-B2B-001] |

### 3.5 Product2 — Sponsorship Package

| Field | 값 |
|---|---|
| Product Name | d'Alba 전광판 광고 + Brand Day 패키지 |
| Record Type | Sponsorship Package |
| Product Code | SPN-2027-DALBA01 |
| Description | [SCN-B2B-001] — "무엇을 얼마에 판매하는가"의 예시(전광판/펜스 광고, Brand Day 프로모션 등) |

Opportunity(3.4)에 Product Line Item으로 연결한다.

### 3.6 Campaign — Collaboration ✅ 확정 (Campaign Record Type)

> **확정 (2026-08-18)**: `P2_TECHNICAL_DECISION_SHEET.md` D안은 Draft 시점에
> Option B(단순 관계/필드)를 권장했지만, 실제 회의 결정은 **Option A — Campaign
> Record Type**이다(`05_DECISIONS.md` Decision 018-D). Campaign 자체에
> RecordType(Collaboration)을 부여하고, Opportunity와의 연결은 별도로 표준
> `Primary Campaign Source`(Opportunity 필드)를 그대로 사용한다 — 두 방식은
> 서로 배타적이지 않다(RecordType=Campaign의 분류, Primary Campaign Source=
> Opportunity와의 연결). Collaboration은 Opportunity Won 이후 필요 시 실행하는
> 수단이며, Phase 2 Sales Pipeline의 중심은 아니다(`00_STORY.md` §8.3).

| Field | 값 |
|---|---|
| Campaign Name | d'Alba Sponsorship Campaign |
| Record Type | Collaboration(B2B) — 정확한 RecordType 이름은 Org 반영 시 확정 |
| 연결 방식 | Opportunity.`Primary Campaign Source` = 이 Campaign |
| Description | [SCN-B2B-001] |

**Campaign Member로 등록할 대상** — 대표 팬층 11명(이하은, 최유진, 강수아, 윤지아, 임소연, 오예린, 황서현, 송다인, 전하율, 곽나연, 노아름)을 Campaign Member로 추가한다.

### 3.7 Quote

| Field | 값 |
|---|---|
| Quote Name | d'Alba Sponsorship Quote |
| Opportunity | d'Alba × Cloud Alpacas — Advertising Sponsorship (3.4) |
| Status | Draft |
| Expiration Date | 2027-02-01 |
| Description | [SCN-B2B-001] |

**QuoteLineItem**

| Field | 값 |
|---|---|
| Product | d'Alba 전광판 광고 + Brand Day 패키지 (3.5, Opportunity Line Item과 동일 Product2 재사용) |
| Quantity | 1 |
| Unit Price | 50,000,000원 |

---

## 4. 이어지는 흐름 (Demo 검증용)

```
Fan Insight(위 11명 Report 집계 — §2 계산 기준대로 입력하면 재현됨)
  → 팬덤 광고 가치 발견(뷰티/라이프스타일 관심)
  → 기업 DB(약 100개) → Agentforce Matching → Top 10 추천(d'Alba, Fit 92, §3.0)
  → Outbound Lead 등록(d'Alba, 김하나, §3.1)
  → Lead Qualification(`Lead_Score__c` 78, Agentforce Fit과 별개)
  → Account/Contact 전환(§3.2~3.3)
  → Opportunity(Advertising Sponsorship, §3.4)
  → Product(전광판 광고+Brand Day 패키지) + Quote(§3.5, §3.7)
  → Campaign(Primary Campaign Source로 연결, Member = 대표 팬층 11명, §3.6)
  → Closed Won → Contract/Sponsorship Revenue
  → Pipeline/Revenue Dashboard 확인 — Demo End Point
  → (Future Scope) 계약 이후 Performance → 장기 재계약/Partnership 판단
```
