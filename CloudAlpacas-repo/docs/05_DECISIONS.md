# 05_DECISIONS.md — 프로젝트 의사결정 기록 (ADR)

> 이 문서는 프로젝트 전체에 영향을 주는 결정(Object 구조, Workflow, Persona, MVP 범위 등)을
> 기록한다(CLAUDE.md §7). 문서 간 내용이 충돌할 때는 이 문서를 최종 기준으로 판단한다.

---

## ADR이 뭔가요?

**ADR(Architecture Decision Record)**은 "우리가 왜 이렇게 하기로 했는지"를 남겨두는 짧은 메모입니다.

비유하자면, 이사할 집을 고를 때 "왜 이 동네로 정했는지"를 적어두는 것과 같습니다. 나중에
"왜 그때 그 동네를 골랐지?"라고 물어보면 다시 기억을 더듬거나 같은 고민을 반복하게 되는데,
그때 이 메모만 보면 바로 답을 알 수 있습니다.

Cloud Alpacas 프로젝트에서도 마찬가지입니다. "왜 실제 팀 이름과 가상 구단 이름을 다르게
정했는지", "왜 문서를 이렇게 나눴는지" 같은 질문에 팀원 누구나 다시 물어보지 않고 이 문서만
보면 답을 찾을 수 있도록 기록합니다.

**형식**: 각 결정은 아래 네 가지를 순서대로 적습니다.

| 항목 | 뜻 |
|---|---|
| 배경 | 왜 이 결정이 필요했나 (어떤 문제/혼란이 있었나) |
| 결정 | 무엇으로 정했나 |
| 이유 | 왜 이 선택이 다른 선택보다 나았나 |
| 영향 | 이 결정 때문에 앞으로 무엇이 달라지나 |

---

## Decision 001 — 팀 정체성 정리: Cellsforce와 Cloud Alpacas

**상태**: 확정
**기록일**: 2026-08-06

### 배경

프로젝트를 처음 접하면 "우리 팀 이름이 Cloud Alpacas인가?", "한화 이글스 데이터를 그대로
쓰는 건가?"처럼 헷갈리기 쉽습니다. 실제 팀과 프로젝트 속 가상의 구단, 그리고 그 구단이
참고한 실제 모델(한화 이글스)까지 세 가지 이름이 등장하기 때문에, 이 관계를 처음부터
명확히 정리해둘 필요가 있었습니다.

### 결정

세 가지 이름의 관계를 다음과 같이 확정한다.

- **Cellsforce** — 이 프로젝트를 수행하는 우리 실제 팀 이름.
- **Cloud Alpacas** — 우리가 실제로 설계하고 만드는 대상. 한화 이글스를 모델링한
  **가상의 프로야구 구단**.
- **한화 이글스** — Cloud Alpacas를 구상할 때 참고한 **실제 모델(reference)**. 우리가
  직접 다루는 데이터나 설계 대상이 아니다.

즉, Cellsforce는 Cloud Alpacas라는 가상 구단의 **Fan Relationship Management(FRM) Team**
역할을 맡아 Salesforce Customer 360을 설계한다.

> **비유**: 드라마 제작진(Cellsforce)이 실존 인물(한화 이글스)에서 영감을 받아 가상의
> 등장인물(Cloud Alpacas)을 만드는 것과 같습니다. 드라마 속에서는 실존 인물의 이름이
> 아니라 등장인물의 이름을 씁니다.

### 이유

- 실제 구단의 비공개 정보를 다루지 않고도, 실제 프로 스포츠 구단과 유사한 현실감 있는
  Business 문제(팬 관리, 멤버십, 굿즈 등)를 자유롭게 설계할 수 있다.
- "가상의 구단"이라는 점을 명확히 해야, 이후 만드는 모든 데이터·화면·시나리오가 창작물임을
  팀 안팎에 혼동 없이 전달할 수 있다.

### 영향

- 모든 문서·화면·데이터에서 실제 구단을 지칭할 때는 **반드시 "Cloud Alpacas"**를 쓴다.
  "한화 이글스"라는 표현은 "Cloud Alpacas가 한화 이글스를 모델링했다"는 관계를 설명할 때만
  예외적으로 사용한다.
- 이후 작성하는 03_SYSTEM.md의 Salesforce Object, 04_DEMO.md의 Demo Story, 샘플 데이터
  등은 모두 Cloud Alpacas 기준으로 작성한다.

---

## Decision 002 — Workflow 분석을 별도 문서로 만들지 않고 01_PROJECT.md에 통합

**상태**: 확정
**기록일**: 2026-08-06

### 배경

프로젝트 초기에는 Domain Model(01_PROJECT.md)과 Workflow 분석(가칭 `02_WORKFLOW.md`)을
서로 다른 문서로 나누는 방안을 고려했었다. 그런데 실제로 작업해보니, Workflow 분석은
"Domain Model이 왜 이렇게 나왔는지"를 검증하는 과정이었고, Domain Model은 그 결과를 담는
그릇이었다 — 즉 두 문서가 사실상 같은 질문("이 세계에 어떤 명사가 필요한가")을 다른
방식으로(Story 관점 vs Workflow 관점) 다시 확인하는 구조였다.

### 결정

Workflow 분석을 별도 문서(`02_WORKFLOW.md`)로 만들지 않고, **01_PROJECT.md 안에서
Domain Model과 함께 다룬다.**

### 이유

- Domain Model과 Workflow는 서로 다른 문서가 아니라 **하나의 사고 흐름**이다: "실제 업무
  (Workflow)를 보고 → 어떤 명사(Entity)가 필요한지 확인하고 → Domain으로 묶는다."
  이 흐름을 문서 두 개로 쪼개면 오히려 앞뒤를 오가며 읽어야 해서 더 헷갈린다.
- CLAUDE.md §7 원칙("같은 내용을 여러 문서에 중복 작성하지 않는다")에 따라, Entity 목록이
  Workflow 분석과 Domain Model 두 곳에 중복 등장하는 것을 피할 수 있다.
- 문서 번호 체계(00~05)를 단순하게 유지할 수 있다 — 문서가 늘어날수록 "어디에 뭐가
  있는지" 찾기 어려워지는 것은 Baby Team에게 특히 부담이 된다.

### 영향

- `02_WORKFLOW.md`라는 파일은 만들지 않는다. 이번 문서 번호 `02`는 대신 `02_TEAM_GUIDE.md`
  (팀 운영 방식)에 배정한다 — CLAUDE.md §8 프로젝트 구조 참고.
- 앞으로 Workflow가 바뀌거나 새로운 Entity가 발견되면, 별도 문서를 새로 만들지 말고
  01_PROJECT.md를 갱신한다.

---

## Decision 003 — Standard First, Custom When Needed

**상태**: 확정
**기록일**: 2026-08-06

### 배경

01_PROJECT.md §6은 Ticket/Membership/Goods 같은 상품과 그 구매를 Salesforce에서 어떤
Object로 만들지에 대해 두 가지 갈림길을 놓고 있었다.

- **상품(§6.3)**: Custom Object로 자유롭게 설계할지, 아니면 Salesforce 표준 `Product2` +
  `Price Book`을 쓸지.
- **구매(§6.5)**: `Standard Order`(이미 확정된 거래)로 만들지, `Standard Opportunity`
  (진행 중인 딜)로 만들지.

이 프로젝트는 Salesforce가 처음인 Baby Team이 Customer 360을 배우는 프로젝트이기도
하다(CLAUDE.md §6) — "표준 기능을 얼마나 쓸지"는 상품/구매 Object 하나만의 문제가 아니라,
프로젝트 전체의 설계 방향을 정하는 질문이었다.

### 결정

**Salesforce 표준 Object를 우선 사용하고, Cloud Alpacas만의 핵심 비즈니스는 필요한
범위에서만 Custom Object로 확장한다.**

구체적으로:

- **판매 가능한 상품** (Ticket, Season Pass, Membership, Goods) → **표준 `Product2` +
  `Price Book`**
- **실제 구매** (Ticket Purchase, Goods Purchase, Membership Enrollment) → **표준
  `Order`**
- **Cloud Alpacas Customer 360의 핵심** (Fan Activity Pattern, Attendance Record,
  Recommendation, Fan Segment, Next Best Action 등) → **Custom Object**

> **비유**: 집을 지을 때 전기 배선·수도 배관처럼 어느 집에나 똑같이 필요한 부분은 표준
> 자재(기성품)를 쓰고, "이 집만의 특징"(우리 가족만을 위한 다락방 구조 등)은 직접
> 설계하는 것과 같습니다. 상품·구매는 어느 커머스 조직에나 필요한 표준 자재이고, 팬을
> 이해하고 다음 행동을 추천하는 부분(Customer 360)이 Cloud Alpacas만의 다락방입니다.

### 이유

- 표준 Object(Product2/Price Book/Order)는 이미 검증된 구조라, 우리가 직접 설계하며
  실수할 여지를 줄여준다 — Baby Team이 표준 패턴을 먼저 익히는 데도 도움이 된다.
  §6.3·§6.5는 원래 "서로 연결된 결정"으로 묶여 있었는데(01_PROJECT.md §6.5 마지막 문단),
  Product2를 쓰기로 하면 Order가 자연스럽게 이어진다.
- 반대로 Fan Segment, Recommendation처럼 이 프로젝트의 핵심 목표(Business Goal — 팬을
  이해하고 성장시키는 것)와 직접 맞닿은 부분은 표준 Object가 표현하지 못하는 개념이라
  Custom Object로 직접 설계해야 한다.
- 결과적으로 "표준으로 충분한 것"과 "우리만의 설계가 필요한 것"을 구분하는 기준이
  생긴다 — 이후 §6의 나머지 결정(Eligibility Rule, Marketing Consent 등)에도 같은
  기준(표준 우선, 필요할 때만 확장)을 적용할 수 있다.

### 영향

- 01_PROJECT.md §6.1 매핑 표의 "Ticket/Season Pass/Membership/Goods/Collaboration
  Item/Benefit"은 03_SYSTEM.md에서 Product2 기반으로, "Ticket Purchase/Goods
  Purchase/Membership Enrollment"는 Order 기반으로 구체화한다.
- Ticket Policy/Membership Tier처럼 "가격·조건을 정의하는" Entity는 Price Book Entry로
  흡수할 수 있는지를 03_SYSTEM.md에서 함께 검토한다.
- Fan Activity Pattern, Attendance Record, Recommendation, Fan Segment는 Custom
  Object로 확정되었으므로, 03_SYSTEM.md에서 바로 Object/Field 설계로 들어간다(별도
  Report/Dashboard 대안 비교는 더 이상 필요 없음).

---

## Decision 004 — 01_PROJECT.md §6 나머지 항목 확정 (Object 설계 착수 전 최종 결정)

**상태**: 확정
**기록일**: 2026-08-06

### 배경

01_PROJECT.md §6은 Decision 003(Product2/Order/Custom Object 구도) 외에도 6개의 개별
갈림길(§6.2, §6.4, §6.6~§6.9)을 팀의 판단에 맡겨두고 있었다. 03_SYSTEM.md에서 Object/Field
설계를 시작하기 전에, 이 항목들을 모두 확정한다. 모든 결정은 CLAUDE.md §5 MVP 원칙("이번
MVP 범위를 벗어나면 Future Scope로 기록한다")에 따라, **지금 필요한 만큼만 만들고 나머지는
Future Scope로 남기는 방향**을 일관되게 따른다.

### 결정

| 항목 | 01_PROJECT.md 참조 | 결정 | 근거 요약 |
|---|---|---|---|
| Fan | §6.2 | **Person Account** | Fan은 압도적 다수의 B2C 개인 고객이며, 직접 구매·이용의 주체다. Fan 한 명 = 레코드 한 개로 자연스럽게 표현된다. |
| Eligibility Rule | §6.4 | **Flow 로직으로만 관리 (Object 없음)** | 규칙 종류가 적고 자주 안 바뀐다. Flow의 Decision 요소로 조건을 직접 구현한다. |
| Ticket Transfer | §6.6 | **Ticket의 필드로만 처리 (Current Owner, Transfer Status)** | 핵심 비즈니스가 아니고, Demo에서 양도 이력을 추적하지 않는다. |
| Marketing Consent | §6.9 | **Person Account의 필드로 관리** (채널별 동의 여부 + 최종 변경 일시) | 감사(Audit) 목적의 이력 추적이 이번 범위에 없다. |
| Renewal | §6.7 중 Renewal | **별도 Object 없이 상태 변경으로 처리** (Membership Enrollment의 Status/Expiration Date) | 갱신은 "새 레코드"가 아니라 기존 가입 상태의 전이로 충분히 표현된다. |
| Partner Store | §6.8 | **별도로 관리하지 않음.** Partner(협업사)는 표준 **Account**를 쓰고, **Record Type**으로 Partner/Sponsor를 구분한다. | 이번 MVP의 협업 대상(예: 산리오)은 매장 단위 관리가 필요 없는 단일 조직이다. |

> Fan Activity Pattern, Attendance Record, Recommendation, Fan Segment는 Decision 003에서
> 이미 Custom Object로 확정되었으므로 이 표에는 포함하지 않는다.

### Future Scope (지금은 만들지 않지만, 나중에 필요해지면 확장하는 지점)

- **Eligibility Rule**: 운영 정책이 자주 바뀌거나 비개발자(Admin)가 직접 규칙을 관리해야
  하면 → Custom Object로 승격.
- **Ticket Transfer**: CS가 양도 이력 조회·다중 양도(A→B→C) 문제를 자주 처리해야 하면 →
  별도 Custom Object(이력 기록)로 승격.
- **Marketing Consent**: Marketing Cloud를 도입하거나 법적 감사 요구가 생기면 → Consent
  History Custom Object로 승격.
- **Renewal**: 갱신 임박 자동 알림, Renewal Campaign이 필요해지면 → 별도 Object 또는
  전용 Flow로 확장.
- **Partner Store**: GS25처럼 여러 매장을 가진 파트너와 협업하게 되면 → Parent Account
  구조 또는 별도 Partner Store 모델로 확장.

### 영향

- 03_SYSTEM.md는 이 표를 기준으로 바로 Object/Field 설계에 들어간다 — §6의 선택지 비교는
  더 이상 반복하지 않는다.
- 위 5개 Future Scope 항목은 03_SYSTEM.md 문서 말미에 "Future Scope" 섹션으로 옮겨
  정리한다(중복 방지, CLAUDE.md §7).

---

## Decision 005 — MVP Object 범위: Sponsorship/Partnership Domain 제외

**상태**: 확정
**기록일**: 2026-08-06

### 배경

01_PROJECT.md는 Cloud Alpacas의 6개 팀(마케팅·티켓·멤버십·굿즈·고객지원·스폰서십) 업무를
모두 분석해 Business Entity를 뽑았다. 하지만 00_STORY.md의 Demo Story는 김매니저가
이루키(신규 팬)를 충성 팬으로 성장시키는 여정만 다루며, 스폰서십/파트너십 업무와는 직접
관련이 없다. 03_SYSTEM.md에서 Object를 설계하기 전에, "업무 분석에 등장한 모든 Entity"와
"이번에 실제로 만드는 Object"가 같은 범위인지 확인이 필요했다.

### 결정

03_SYSTEM.md의 Object 설계는 **Fan / Marketing / Ticket / Membership / Goods / Service
Domain**에만 집중한다. **Sponsor, Partner, Proposal, Sponsor Contract, Settlement,
Sponsorship Package** 등 스폰서십·파트너십 관련 Object는 이번 MVP 설계·구현 범위에서
**제외**한다.

### 이유

- CLAUDE.md §2의 Business Goal("신규 팬을 이해하고... 충성 팬으로 성장시키고...")과
  00_STORY.md의 Demo Story 모두 팬 개인의 여정에 초점이 있다 — 스폰서십은 이 여정에
  등장하지 않는다.
- CLAUDE.md §5 MVP 원칙: "새로운 아이디어가 나오더라도 MVP 범위를 벗어나면 바로 구현하지
  않고 Future Scope로 기록한다." 스폰서십 Domain은 실제 업무상으로는 존재하지만, 이번
  Demo가 증명해야 하는 범위 밖이다.
- Object 수를 줄이면 Baby Team이 Org 구조를 이해하고 관리하기에도 더 수월하다.

### 영향

- 03_SYSTEM.md는 Sponsor/Partner 관련 Object를 만들지 않는다.
- 01_PROJECT.md §4의 Partnership Domain Entity(Sponsor, Partner, Partner Contact,
  Sponsorship Package, Proposal, Sponsor Contract, Settlement, Sponsor Performance,
  Collaboration Item, Partner Store)는 **Future Scope**로 남긴다 — 향후 산리오와 같은
  협업사·스폰서십 관리 기능이 필요해지면 이 Entity 목록을 그대로 재사용해 확장한다.
- Campaign, Benefit처럼 Marketing/Operations와 Partnership이 공유하던 Entity는
  Marketing/Operations 쪽 용도로만 이번에 설계한다.

---

## Decision 006 — 03_SYSTEM.md Object 개수 최소화 (경기장 구조 · Notification · Benefit · 배송)

**상태**: 확정
**기록일**: 2026-08-06

### 배경

Decision 003~005로 큰 틀(Person Account, Product2+Order, Custom Object 범위)은 정해졌지만,
Object/Field 설계에 착수하기 전 4개의 세부 항목이 더 남아 있었다 — 모두 "Object를 몇 개나
만들 것인가"에 영향을 주는 항목이라 먼저 확정한다.

### 결정

| 항목 | 결정 | 근거 요약 |
|---|---|---|
| 경기장 구조 (Ballpark/Section/Seat/Gate) | **별도 Object 없음.** 좌석 정보(Section, Row, Seat Number, Gate)는 티켓 관련 필드로만 관리 | Cloud Alpacas는 단일 홈구장 MVP. 구역별 선호 분석은 필드만으로 충분히 가능하다. |
| Notification | **Custom Object(Notification Log)로 기록** | Fan Timeline의 핵심 데이터. Flow가 레코드를 만들고, 그 레코드를 근거로 Slack 알림을 보낸다 — "언제 어떤 안내를 보냈는지"가 이력으로 남아야 한다. |
| Benefit / Benefit Redemption | **Benefit만 Custom Object로 관리.** 사용 여부는 Benefit의 Status 필드(Issued/Used/Expired)로 표현하고, 별도 Redemption Object는 만들지 않음 | Recommendation의 결과로 발급되는 개인화 혜택을 표현하는 데는 상태 필드만으로 충분하다. |
| Shipment / Return | **Future Scope로 제외.** Goods Purchase(Order)까지만 구현 | 이 프로젝트의 목적은 물류가 아니라 Customer 360이다. Demo Story에도 배송·반품 장면이 없다. |

### Future Scope

- **경기장 구조**: 다구장 운영이나 좌석 상태(예약됨/사용됨) 관리가 필요해지면 → Ballpark /
  Section / Seat Object로 확장.
- **Benefit Redemption**: 혜택 사용 이력을 별도로 분석하거나 정산해야 하면 → Benefit
  Redemption Object 추가.
- **Shipment / Return**: 배송 추적, 교환·반품 처리 프로세스가 필요해지면 → 두 Object를
  새로 추가.

### 영향

- 03_SYSTEM.md의 Object 목록은 위 4가지 결정을 그대로 반영한다.
- 좌석 정보 필드는 "언제 시점의 정보인가"에 따라 두 곳으로 나뉜다 — 좌석 배정(Section,
  Row, Seat Number)은 구매 시점 정보라 **OrderItem**에, 실제 입장 게이트(Gate)는 입장
  시점 정보라 **Admission**에 둔다. 이 구분은 03_SYSTEM.md에서 필드 단위로 설명한다.

---

## Decision 007 — 팀 역할 재정의: 직함을 "무엇을 만드는 사람인가"로 다시 표현

**상태**: 확정
**기록일**: 2026-08-07

### 배경

기존 직함(Salesforce Admin Lead, Platform Lead / QA Lead, Demo Lead / Business
Analyst)은 Salesforce를 처음 접하는 Baby Team에게 "이 사람이 정확히 무엇을 하는
사람인지" 바로 와닿지 않았다. 특히 Business Analyst 역할이 "Demo Lead"라는 이름
때문에 완성된 결과를 마지막에 검사하는 사람처럼 오해되기 쉬웠고, 승우와 혜준의
역할 경계(누가 화면을 만드는가)도 명확하지 않았다.

### 결정

팀원 직함과 책임 범위를 아래와 같이 재정의한다.

| 담당자 | 기존 직함 | 새 직함 |
|---|---|---|
| 승우 | Salesforce Admin Lead | **Salesforce Builder** |
| 혜준 | Platform Lead / QA Lead | **Salesforce Experience Lead / QA Lead** |
| 아론 | Demo Lead / Business Analyst | **Business Analyst / Demo Experience Lead** |

직함 변경과 함께 아래 책임도 재배분한다.

- **화면(Lightning Page/App) 구현**은 승우(Salesforce Builder)에서 **혜준(Salesforce
  Experience Lead)**으로 이동한다 — "데이터 구조를 만드는 것"과 "그 구조를 직원이 쓰기
  좋게 완성하는 것"은 서로 다른 책임이라는 점을 직함에 정확히 반영하기 위함이다. 승우는
  화면이 참조하는 Object/Field가 정확한 데이터를 갖도록 지원하는 역할로 남는다.
  혜준은 Salesforce Admin 자격증을 보유하고 있어 Platform(화면·권한) 영역과 운영(Admin:
  QA·UAT·배포) 영역을 함께 담당한다.
- **아론(Business Analyst)**의 역할은 "완성된 결과를 검증하는 사람"이 아니라 "Customer
  Journey와 Business Story를 함께 설계하고, Demo가 자연스럽게 전달되도록 만드는 사람"
  으로 명확히 표현한다. Object나 Field를 먼저 찾지 않고 Business Story를 먼저 만든 뒤
  그 Story에 필요한 Object를 함께 찾는 순서(CLAUDE.md §3 Business First)는 그대로
  유지된다 — 바뀐 것은 표현 방식이지 실제 작업 순서가 아니다.
- 은영님의 로마자 표기를 "Eunyoung"에서 **"Eunyeong"**으로 통일한다 — 온보딩 문서
  파일명도 `02_EUNYOUNG.md`에서 `02_EUNYEONG.md`로 변경한다.

### 이유

- CLAUDE.md §6은 Claude와 팀 모두에게 "어려운 용어를 먼저 사용하지 않는다"를 요구한다
  — 직함도 예외가 아니다. "이 사람이 자동차의 어느 부분을 만드는가"라는 비유
  (02_TEAM_GUIDE.md §1-1)로 설명하면 Salesforce 경험이 없어도 즉시 이해할 수 있다.
- 다섯 역할이 Sara(무엇을 만들지) → 아론(이야기가 자연스러운지) → 승우(데이터 구조) →
  혜준(직원이 쓰기 좋은 환경) → 은영(실제 동작)의 순서로 연결된다는 것
  (02_TEAM_GUIDE.md §1-2)을 직함에서도 드러내야 "내 일이 왜 필요한지"가 분명해진다.
- 실제 작업 범위(Responsibility)는 바뀌지 않았다 — Object/Field/Flow 구조는 여전히
  승우가, Business Story·Demo는 여전히 아론이 이끈다. 이번 결정은 **표현과 책임 경계를
  명확히 하는 리팩토링**이며, MVP 범위나 Object 설계를 바꾸지 않는다.

### 영향

- `02_TEAM_GUIDE.md`(SSOT)와 `docs/members/*.md` 전체가 이 표를 기준으로 갱신되었다.
- `02_TEAM_GUIDE.md` §2(Object/Flow/Screen 담당) 표의 화면 담당 행이 "혜준(구현·QA),
  승우(데이터 연동 지원)"으로 바뀌었다.
- 이후 팀원 역할이 다시 바뀌면 이 Decision처럼 배경/결정/이유/영향을 기록한 뒤
  `02_TEAM_GUIDE.md`를 먼저 고치고 `docs/members/*.md`를 맞춘다(CLAUDE.md §7).

---

## Decision 008 — 은영의 역할 명확화: "연동 담당"이 아니라 "커스텀 개발 전체" 담당

**상태**: 확정
**기록일**: 2026-08-07

### 배경

기존 은영의 역할 설명(Decision 007 이전부터)은 "Demo Fan App 개발과 Salesforce
연동"에만 초점이 맞춰져 있었다. 하지만 실제로 Developer Lead가 필요한 이유는
"Fan App만 만들기 위해서"가 아니라, **Salesforce 표준 기능(Flow, 표준 화면 등)만으로
해결이 안 되는 부분을 코드로 만들기 위해서**다 — LWC, Apex, 외부 시스템 연동
아키텍처가 전부 여기 포함된다. "연동"이라는 좁은 표현이 이 역할의 진짜 크기를
가리고 있었다.

### 결정

은영의 역할을 **Developer Lead**로 명확히 하고, 책임 범위를 아래와 같이 확장한다.

| 영역 | 내용 | 원칙 |
|---|---|---|
| Fan App | Demo MVP Fan App 개발(로그인, 티켓/굿즈 구매, QR 체크인 등) | 기존과 동일 |
| LWC | 표준 컴포넌트로 부족할 때 커스텀 Lightning Web Component 개발 | **표준 우선** — 화면 레이아웃 조립(Lightning Page)은 혜준(Salesforce Experience Lead)이 하고, 그 안에 들어가는 개별 커스텀 부품만 은영이 코드로 만든다 |
| Apex | Flow로 처리하기 어려운 복잡한 로직만 개발 | **Flow 우선**(Decision 003의 "Standard First, Custom When Needed"를 코드 레벨로 확장) — `03_SYSTEM.md` §4.6에 이미 후보로 기록된 항목(예: `Fan_Activity_Pattern__c` 재계산)이 실제 대상이다 |
| Salesforce API 연동 | Fan App → Salesforce 데이터 전달 | 기존과 동일 |
| Slack 연동 | Slack App/Webhook 설정과 메시지 Payload 형식 | 은영이 기술 아키텍처를 주도하고, Flow 안에서 이를 호출하는 것은 승우가 담당한다(`02_TEAM_GUIDE.md` §2 갱신) |
| Agentforce | Fan Summary, Next Best Action 설명 등 | **🔵 Future Scope** — CLAUDE.md §5에 따라 이번 MVP 범위 밖이다. 은영의 장기 역할에는 포함하되, 지금 만들지 않는다 |

**베이비 팀을 위한 한 줄 원칙**: "Salesforce 표준 기능을 먼저 쓰고, 표준으로 안 될
때만 개발한다." — Fan App을 제외한 모든 영역(LWC/Apex/Agentforce)에 이 원칙을
그대로 적용한다.

### 이유

- Decision 003이 Object 설계에 적용한 "표준 우선, 필요할 때만 확장" 원칙을 코드
  레벨(LWC/Apex)까지 일관되게 확장하면, Baby Team이 "언제 Apex를 써도 되는가"를
  매번 새로 고민하지 않고 같은 기준으로 판단할 수 있다.
- Agentforce를 완전히 빼지 않고 "은영의 스킬셋"으로는 남겨둔 이유는, MVP 이후
  Future Scope로 확장할 때 누가 이 작업을 맡을지 미리 명확히 해두기 위해서다 —
  다만 CLAUDE.md §5가 이미 MVP 범위 밖으로 명시했으므로, 지금 당장의 Responsibility로
  포함하지는 않는다.
- Slack 연동의 소유권을 "은영 주도, 승우 보조"로 재정리한 것은, Webhook/Payload
  설계가 Flow 로직보다 코드/API 성격이 강해 Developer Lead의 책임 범위와 더
  자연스럽게 맞기 때문이다.

### 영향

- `02_TEAM_GUIDE.md` §1의 Developer Lead 책임 영역 설명과 §2의 Slack 연동 담당
  행이 이 표를 기준으로 갱신되었다.
- `docs/members/02_EUNYEONG.md`가 이 표를 기준으로 갱신되었다 — Owned Flows(Apex
  후보 언급), Owned Screens(LWC와 혜준의 화면 조립 관계) 섹션이 함께 바뀌었다.
- Agentforce 관련 작업은 이후 팀이 MVP 범위를 공식적으로 넓히기로 결정할 때
  별도 Decision으로 다시 다룬다 — 이번 Decision은 "누가 맡을지"만 미리 정해둔
  것이지, MVP 범위 자체를 넓히는 결정이 아니다.

---

## Decision 009 — Fan 분류 체계 3축 분리, Owner 독립, Purchase Channel, Engagement 필드/로직 분리

**상태**: 확정
**기록일**: 2026-08-11

### 배경

Fan Profile 화면에 무엇을 보여줄지("최근 관람일, 총 관람 횟수, 구매 금액/빈도, 최근 활동,
Engagement, Fan Value, Current Segment") 정리하는 과정에서, 그동안 문서 곳곳에서
**"Segment"라는 단어가 서로 다른 세 가지 의미로 혼용**되어 왔다는 것이 드러났다.

- `00_STORY.md` §6 "Fan Segment"는 **팬의 현재 상태(Life Cycle)** — New Fan/Active
  Fan/At-Risk Fan 등 — 를 가리킨다.
- `01_PROJECT.md` §2.1(마케팅 Workflow)·§3.1의 "Fan Segment"는 원래 **캠페인 발송
  대상을 묶은 그룹**(마케팅 세분화)을 가리키는 다른 개념으로 제안됐다.
- `Fan_Segment_History__c`(03_SYSTEM.md)는 실제로는 위 둘 중 **Life Cycle 쪽으로만**
  구현됐다 — 마케팅 대상 그룹이라는 원래 의미는 Object로 만들어지지 않았다.
- Flow와 Demo Scene 곳곳의 "VIP 후보"(00_STORY.md §2, 03_SYSTEM.md §4.5,
  04_DEMO.md Scene 7)는 Membership Tier의 `VIP`(Product2.`Tier__c`) 값과도, 아직
  존재하지 않는 "이 팬이 얼마나 가치있는 고객인가"라는 판단과도 뒤섞여 쓰이고 있었다.
- Owner(담당 직원)가 Fan 분류와 같은 축인지 다른 축인지도 문서에 명시된 적이 없었다.

이 혼용을 그대로 두면 다가오는 Org 구현 단계에서 "Segment"라는 이름의 필드/Object를
무엇으로 만들지 팀마다 다르게 이해할 위험이 있다.

### 결정

**1. Fan 분류는 반드시 서로 독립된 3개의 축으로 관리한다.**

| 축 | 값 | 의미 |
|---|---|---|
| **Current Segment / Life Cycle** | New / Active / Dormant / At-Risk / Churned / Unreachable | 지금 이 팬이 활동 주기의 어디에 있는가(`00_STORY.md` §6과 동일 — 값 목록 변경 없음) |
| **Engagement Level** | 가입 → 관심 → 활동 → 충성 → 멤버십 → 핵심 | 이 팬이 우리와 얼마나 깊게 관계를 맺고 있는가 |
| **Fan Value** | 일반 / 우수 / VIP | 이 팬이 우리에게 얼마나 가치 있는 고객인가 |

앞으로 어떤 문서에서도 "Segment"라는 단어 하나로 이 세 가지를 혼용하지 않는다.
**VIP는 Fan Value 값이다** — Membership Tier(Product2.`Tier__c`)의 "VIP" 상품 등급과는
다른 개념이며, "VIP 후보"라는 기존 Flow/Demo 표현은 Fan Value가 VIP로 바뀔 가능성이
높은 후보를 가리키는 것이지, 자동으로 `Fan_Value__c`를 VIP로 확정하는 것이 아니다.

**2. Owner(담당 직원)는 Fan 분류와 완전히 별개의 축이다.**

Owner = 담당 직원, Fan Value = 고객 가치, Current Segment = 현재 고객 상태는 서로
독립적으로 조합될 수 있다 — 예를 들어 김매니저가 담당하는 VIP이면서 동시에 At-Risk인
Fan이 존재할 수 있다. 현재는 김매니저 1명뿐이므로 OWD/Sharing Rule/Role 기반 접근
제한은 구현하지 않는다. Owner(표준 `OwnerId`) 구조 자체는 유지하고, Staff가 늘어나면
접근 권한/Sharing 전략을 Future Scope에서 별도로 결정한다.

**3. Order의 Purchase Channel(온라인/구장 굿즈샵)을 관리한다.**

Fan Journey, Fan Profile, Dashboard, Recommendation에서 온라인 구매와 구장 현장 구매를
구분해 활용하기로 했으므로, `Purchase_Channel__c` 필드로 관리한다.

**4. Engagement Score/Level은 "필드 정의"와 "계산 로직"을 구분해 문서화한다.**

계산 공식(어떤 활동에 몇 점을 주고 어느 점수 구간이 어느 Level인지)은 아직 확정되지
않았다. 공식이 없다고 해서 이번 MVP에서 필요한 Fan 데이터 자체를 Marketing Cloud
도입 이후로 미루지 않는다 — 필드와 값 목록은 지금 정의하고, 계산 로직은 미확정(TBD)
상태로 명시해 둔다.

**5. Sales Cloud MVP를 우선 구현하며, 지금까지의 Object/Fan 360 설계를 뒤집지 않는다.**

Marketing Cloud Next / Data Cloud / Tableau 등은 CLAUDE.md §5에서 이미 Future Scope로
분류된 원칙을 재확인한다. 이 확장 경로(Sales Cloud Fan Data → Data Cloud → Segment
Builder → Marketing Cloud Next → Campaign/Journey/Personalization → 성과 분석)는
`03_SYSTEM.md` §5 Future Scope에 참조용으로 한 줄만 남기고, 현재 MVP Object를
Marketing Cloud 전용 구조로 미리 재설계하지 않는다. 실제 Org 구현 이후 고도화 여부를
다시 결정한다.

### 이유

- Fan Profile처럼 실제 화면을 설계하는 순간 "Segment 하나"로는 "이 팬이 지금 뭘 하고
  있는가"(Life Cycle), "얼마나 깊이 관여하는가"(Engagement), "얼마나 가치 있는가"(Value)를
  동시에 표현할 수 없다는 것이 드러났다 — 세 질문은 서로 다른 답을 가질 수 있다(예:
  Dormant지만 과거 누적 가치가 높아 여전히 VIP인 팬).
- VIP를 Membership Tier와 뒤섞으면 "VIP 멤버십 상품을 산 사람"과 "우리가 VIP로 판단한
  사람"이 항상 같다고 잘못 가정하게 된다 — 실제로는 다를 수 있다(VIP 멤버십을 아직 안
  샀어도 Fan Value가 VIP인 팬이 있을 수 있다).
- Owner와 Fan 분류를 분리해야, 나중에 Staff가 늘어나 담당자를 배정하더라도 "그 담당자가
  맡은 팬이 자동으로 특정 Segment/Value가 된다"는 잘못된 결합을 방지할 수 있다.
- CLAUDE.md §5 MVP 원칙("고도화 여부는 실제 Org 구현 이후 결정한다")과 §7 원칙(전체에
  영향을 주는 변경은 Decision으로 기록)을 그대로 따른 것이다 — 이 Decision은 새 기능을
  추가하는 것이 아니라, 이미 여러 문서에 흩어져 암묵적으로 쓰이던 개념을 하나의 기준으로
  정리한 것이다.

### 영향

- `00_STORY.md` §6: "Fan Segment" 표가 3축 중 **Current Segment(Life Cycle)** 만
  다룬다는 점을 명시한다. 표의 값 자체는 바뀌지 않는다.
- `01_PROJECT.md` §3.1·§4: "Fan Segment" Entity가 Life Cycle 쪽으로 구현되었고,
  마케팅 대상 그룹이라는 원래 개념은 별도 Entity 없이 필요해지면 §6.10의 List
  View/Report 대안으로 다룬다는 주석을 추가한다. 기존 분석 내용(왜 그렇게 추론했는지)은
  삭제하지 않는다.
- `03_SYSTEM.md` §2.1(Person Account): `Engagement_Level__c`, `Fan_Value__c` 필드를
  추가한다. `Current_Segment__c`와 함께 3축이 모두 Person Account에 캐시되고,
  원본 이력은 각각 별도 Object(`Fan_Segment_History__c` 등)가 담당하는 기존 원칙(§2.1
  캐시/이력 분리 설명)을 그대로 따른다.
- `03_SYSTEM.md` §2.4(Order): `Purchase_Channel__c` 필드를 추가한다.
- `03_SYSTEM.md` §5(Future Scope): Engagement Score 계산 공식 확정, OWD/Sharing Rule
  확장, Marketing Cloud Next 확장 파이프라인을 항목으로 추가한다.
- `04_DEMO.md` §4 화면 목록: Fan Profile이 보여주는 항목을 이 Decision의 3축 + 관람/구매
  요약 기준으로 구체화한다.
- `docs/data/DEMO_DATASETS.md`: Order 레코드에 `Purchase_Channel__c` 값을 채운다.

---

## Decision 010 — Org 구현 착수 전 최종 확정: 필드명(`Fan_Value_Tier__c`), `Engagement_Score__c` 신설, VIP 후보 흐름/이력 범위 재확인

**상태**: 확정
**기록일**: 2026-08-11

### 배경

Decision 009로 Fan 분류 3축의 **개념**은 정리됐지만, Org에서 실제로 Object/Field를
만들기 하루 전 시점에 두 가지가 더 필요했다.

- Decision 009는 Fan Value 축의 필드명을 `Fan_Value__c`로 임시 표기했다. 그런데 이
  필드가 담는 값은 "일반/우수/VIP"라는 **등급(Tier)**이지, "가치가 얼마인지"를 나타내는
  숫자(LTV 등)가 아니다 — `Fan_Value__c`라는 이름만 보면 나중에 숫자 필드로 오해하거나,
  누군가 별도로 LTV 숫자 필드를 또 만들어버릴 위험이 있었다.
- Fan Profile에 "Engagement" 하나만 표시하기로 했던 초기 논의와 달리, 실제로는
  **Engagement Level(범주 — 가입/관심/활동/충성/멤버십/핵심)**과 **Engagement Score
  (그 범주를 산출하는 근거 점수)**가 서로 다른 목적의 값이라는 것이 Fan Profile 요구사항
  ("Engagement Score, Engagement Level"을 나란히 요구)에서 드러났다. `Engagement_Level__c`
  하나로는 이 둘을 구분할 수 없었다.
- VIP 후보 감지 Flow의 "감지 → Recommendation → 담당자 확인 → (필요 시) Action"이라는
  4단계 흐름이 03_SYSTEM.md §4.5에 암묵적으로만 존재했고, "VIP 후보 감지 ≠ Fan Value
  자동 변경"이라는 등식이 문서에 명시적으로 박혀 있지 않았다.
- `Fan_Segment_History__c`가 Current Segment(Life Cycle) 전용인지, 3축 전체의 이력을
  다 받는 Object로 확장될 수도 있는지가 Decision 009에는 여지로 남아 있었다.

### 결정

**1. Fan Value 축의 필드명을 `Fan_Value_Tier__c`로 확정한다.** (Decision 009의
`Fan_Value__c`를 대체 — 값은 그대로 일반/우수/VIP)

**2. `Engagement_Score__c`(Number) 필드를 신설한다.** `Engagement_Level__c`(범주값)와는
별개의 필드다 — Score는 Level을 산출하는 근거 점수라는 관계다. **필드 자체는 이번 MVP에
포함해 확정하지만, 점수 계산 공식과 자동 계산 방식(Flow/Apex 등)은 이번에 확정하지
않는다(TBD)** — "관람 30점 + 구매 40점 + 활동 30점" 같은 임의의 배점을 지금 만들어
확정하지 않는다.

**3. `Engagement_Level__c`의 값 레이블을 "가입 팬/관심 팬/활동 팬/충성 팬/멤버십
팬/핵심 팬"으로 통일한다.** Current Segment가 "New Fan/Active Fan/..."처럼 "Fan"을
붙이는 표기 스타일과 일치시킨 것이며, Decision 009가 정의한 6단계(가입→관심→활동→충성→
멤버십→핵심) 자체는 바뀌지 않는다.

**4. VIP 후보 감지 Flow의 4단계 흐름을 명문화한다.**
`Fan_Activity_Pattern__c`(행동 데이터) 기준 VIP 조건 충족 감지 → `Recommendation__c`
생성 → 담당자(김매니저)에게 Slack 알림 → **담당자 확인** → 필요 시 담당자가 직접
`Fan_Value_Tier__c`를 VIP로 변경(수동). **"VIP 후보 감지" ≠ "Fan Value = VIP 자동
변경"**이며, 이 Flow는 어떤 경우에도 `Fan_Value_Tier__c`를 자동으로 쓰지 않는다.

**5. `Fan_Segment_History__c`는 Current Segment(Life Cycle) 변경 이력 전용임을
재확인한다.** Engagement Level/Fan Value 변경 이력까지 이 Object 하나로 통합하지
않는다 — 두 축이 이력 추적이 필요할 만큼 중요해지면 각각 별도 이력 Object를 새로
만든다(Future Scope, Decision 009와 동일한 "Object는 필요한 만큼만" 원칙).

**6. 아래 항목은 Decision 009에서 이미 정한 대로 변경 없이 재확인만 한다** — 이번
결정으로 다시 논의하거나 확장하지 않는다.
- `Purchase_Channel__c`(Order, 값: 온라인/구장 굿즈샵)는 Marketing Cloud 때문이 아니라
  현재 Sales Cloud MVP의 Fan Journey/Fan Profile/Dashboard/Recommendation에서 바로
  쓰이므로 **MVP 확정 항목**이다 — Future Scope로 재분류하지 않는다.
- Owner(표준 `OwnerId`)는 Fan 분류 3축과 완전히 별개이며, 김매니저 1명뿐인 현재는
  OWD/Sharing Rule/Role Hierarchy/Queue를 추가 구현하지 않는다. OWD를 Private으로
  바꾸거나 VIP 담당자별 Sharing Rule을 새로 만들지 않는다.
- Marketing Cloud Next/Data Cloud 확장 파이프라인은 참조용 한 줄(Sales Cloud Fan Data
  → Data Cloud → Segment Builder → Marketing Cloud Next → Campaign/Journey/
  Personalization → 성과 분석)로만 Future Scope에 남기고, 현재 MVP Object를 Marketing
  Cloud 전용 구조로 미리 재설계하지 않는다.

### 이유

- `Fan_Value_Tier__c`로 이름을 바꾼 이유는 필드명만 보고도 "이건 등급 Picklist"임을
  알 수 있게 하기 위해서다 — Baby Team이 내일 Org에서 Object를 만들 때, 필드명이
  값의 성격(등급 vs 숫자)을 스스로 설명해야 매번 이 문서를 다시 찾아보지 않아도 된다.
- `Engagement_Score__c`를 `Engagement_Level__c`와 분리한 이유는 Fan Profile 요구사항이
  둘을 나란히 요구했고, 실제로도 "지금 몇 단계인가"(Level)와 "그 판단의 근거 수치가
  얼마인가"(Score)는 화면에서 다른 자리에 다른 목적으로 쓰이기 때문이다 — 다만 계산
  공식을 지금 정하면 나중에 실제 운영 데이터로 검증하기도 전에 잘못된 배점이 굳어질
  위험이 있어, 필드만 만들고 공식은 TBD로 남긴다(CLAUDE.md §5 MVP 원칙 — 고도화는
  실제 Org 구현 이후 결정).
- VIP 후보 흐름을 4단계로 명문화한 이유는, "감지"와 "확정"을 같은 것으로 오해하면
  Flow가 사람의 판단 없이 VIP 등급을 함부로 확정해버리는 것으로 잘못 구현될 위험이
  있기 때문이다 — 담당자의 최종 확인이라는 단계를 문서에 고정해두면 Flow 설계자(승우)와
  QA(혜준) 모두 같은 기준으로 검증할 수 있다.
- 나머지 항목(Purchase Channel, Owner/OWD, Marketing Cloud Next)을 "재확인"으로 명시한
  이유는, Decision 009에서 이미 내린 결정을 다시 논쟁거리로 되돌리지 않기 위해서다 —
  이 Decision의 목적은 새로 정하는 것이 아니라 Org 구현 직전에 흔들리지 않을 단일
  기준을 남기는 것이다(CLAUDE.md §7).

### 영향

- `03_SYSTEM.md` §2.1(Person Account): `Fan_Value__c` → `Fan_Value_Tier__c`로 필드명을
  바꾸고, `Engagement_Score__c`(Number, 계산 공식/자동화 TBD) 필드를 추가한다.
  `Engagement_Level__c`의 값 레이블을 "가입 팬/관심 팬/활동 팬/충성 팬/멤버십 팬/핵심
  팬"으로 갱신한다. Owner가 3축과 별개라는 설명, 이력 Object가 Current Segment 전용이라는
  설명을 보강한다.
- `03_SYSTEM.md` §4.5(VIP 후보 감지 Flow): 4단계 흐름과 "감지 ≠ 자동 변경" 문구를
  명시한다.
- `03_SYSTEM.md` §5(Future Scope): `Engagement_Score__c` 계산 공식/자동 계산 방식을
  구분해 항목을 추가하고, OWD 관련 표현에 Role Hierarchy/Queue를 포함한다.
- `04_DEMO.md` §4 Fan Profile 화면 설명에 Engagement Score, Membership 가입 여부를
  추가하고 필드명을 `Fan_Value_Tier__c`로 갱신한다.
- `docs/data/DEMO_DATASETS.md`, `docs/data/SAMPLE_DATA.md`: `Fan_Value__c` 표기를
  `Fan_Value_Tier__c`로 갱신하고, `Engagement_Score__c`를 TBD로 표기한다(임의의 예시
  점수를 확정 공식처럼 기록하지 않는다).

---

## Decision 011 — Season Object 도입, Game__c/Fan_Activity_Pattern__c 재설계 (Master-Detail + Roll-Up)

**상태**: 확정
**기록일**: 2026-08-11

### 배경

시즌별로 팬의 관람 참여도를 정량적으로 비교하고("이 팬이 2025시즌보다 2026시즌에 더
자주 왔는가"), 관람률(%)을 계산해야 한다는 필요가 제기됐다. 기존
`Fan_Activity_Pattern__c.Period__c`(Text)는 "2026 시즌"처럼 자유 텍스트로만 기간을
표현해서, 시즌 전체 경기 수·진행 경기 수 같은 집계 기준이 될 수 없었다. Game도
"예정/진행/취소" 상태나 홈/원정 구분이 없어, 취소된 경기까지 관람률 분모에 들어가는
문제가 있었다.

### 결정

**1. `Season__c`를 신규 Custom Object로 만든다.**

| Field (API Name) | 타입 | 설명 |
|---|---|---|
| Name | Text | 예: "2026 시즌" |
| `Total_Games__c` | Number | 시즌 전체 경기 수(취소 포함, 수동 입력) |
| `Played_Games__c` | Roll-Up Summary (COUNT, `Game__c.Status__c = Played`) | 실제 진행 경기 수 — 관람률 계산의 분모 |

**2. `Game__c` → `Season__c`는 Master-Detail(Master = Season)로 연결한다.** `Home_Away__c`
(Picklist: Home/Away), `Status__c`(Picklist: Scheduled/Played/Cancelled) 필드를
추가한다. 관람률 계산 시 `Status__c = Cancelled`인 경기는 분모에서 제외한다.

이 관계 타입은 별도로 논의하지 않고 **기존에 이미 승인된 결정의 기술적 연장**으로
확정한다 — `Played_Games__c`를 Roll-Up으로 자동 집계하기로 이미 정했고(아래 §3),
Admission__c↔Attendance_Record__c도 같은 이유로 Master-Detail을 확정했다(Decision
012). Lookup으로 하면 `Played_Games__c`를 누군가 수동으로 세야 하는데, 이는 "경기
취소/진행 여부를 자동 반영한다"는 이번 결정의 취지에 어긋난다.

**3. `Fan_Activity_Pattern__c`를 Fan + Season 기준으로 재설계한다.** `Period__c`(Text)를
삭제하고 `Season__c`(Lookup)를 추가한다 — 한 Fan은 시즌별로 하나의 Activity Pattern을
가진다("Fan A + 2025", "Fan A + 2026"처럼). `Attendance_Rate__c`(Formula, Percent)를
추가한다 — 별도 저장 없이 `Games_Attended__c ÷ Season__r.Played_Games__c × 100`으로
계산한다.

> 예: 시즌 예정 경기 144경기 / 취소 2경기 / 실제 진행 142경기 / 팬 관람 36경기 →
> 관람률 25.35%

**4. MVP는 시즌 단위 집계로 구현한다.** 월별/분기별 Pattern은 Future Scope로 둔다.

**5. `Fan_Activity_Pattern__c`에 `Fan__c` + `Season__c` 조합 기준 Duplicate Rule을
추가한다** — 한 팬은 한 시즌에 Activity Pattern을 1건만 가질 수 있도록 Block한다
(Matching Rule: 두 필드 모두 Exact).

### 이유

- Season을 Object로 만들지 않으면 "시즌 전체 경기 수"와 "실제 진행 경기 수"를 어딘가
  수동으로 관리해야 하고, 경기 취소가 생길 때마다 관람률 계산이 틀어진다 — Object로
  집계 기준 자체를 자동화하는 것이 Baby Team의 운영 부담을 줄인다.
- `Period__c`(Text)를 유지하면 "2026 시즌"과 "2026시즌"처럼 표기가 흔들려도 시스템이
  감지하지 못한다. `Season__c`(Lookup)로 바꾸면 오타로 인한 중복/누락을 Duplicate
  Rule로 원천 차단할 수 있다.
- Master-Detail을 Lookup 대신 선택한 이유는 Decision 012와 동일한 원칙(Roll-Up
  자동화가 필요한 관계는 Master-Detail로 만든다)을 일관되게 적용하기 위함이다.

### 영향

- `03_SYSTEM.md` §1.2: Custom Object 목록에 `Season__c` 추가.
- `03_SYSTEM.md` §2: `Season__c` 필드 상세 섹션 신설, `Game__c`에 `Season__c`/
  `Home_Away__c`/`Status__c` 추가, `Fan_Activity_Pattern__c`의 `Period__c` 삭제 →
  `Season__c`/`Attendance_Rate__c` 추가.
- `03_SYSTEM.md` §3(ERD): `Season__c`↔`Game__c`, `Season__c`↔`Fan_Activity_Pattern__c`
  관계를 추가한다.
- `01_PROJECT.md` §4(Business Entity 목록), §6.1(전체 매핑 표): Season Entity를
  추가한다(이번 Workflow 분석 이후 새로 확정된 Entity로 표시).
- `docs/data/DEMO_DATASETS.md`, `docs/data/SAMPLE_DATA.md`: Season 레코드와
  `Fan_Activity_Pattern__c`의 `Period__c` 값을 `Season__c` 참조로 갱신해야 한다(다음
  데이터 작업 시 반영).

---

## Decision 012 — Admission__c ↔ Attendance_Record__c를 Master-Detail로 전환, 집계는 Roll-Up Summary로 처리

**상태**: 확정
**기록일**: 2026-08-11

### 배경

`Attendance_Record__c.Total_Admissions__c`/`First_Admission_Date__c`/
`Last_Admission_Date__c`가 실제로 "누가 언제 갱신하는지"가 문서에 명확히 정의된 적이
없었다 — 사실상 수동 또는 별도 집계 Flow에 의존한다고 암묵적으로 가정하고 있었다.
팬 수가 늘어나면 이런 수동/Flow 집계는 누락되거나 느려질 위험이 있다.

### 결정

`Admission__c.Attendance_Record__c`를 **Master-Detail**(Detail = `Admission__c`,
Master = `Attendance_Record__c`)로 추가한다. `Total_Admissions__c`(COUNT),
`First_Admission_Date__c`(MIN, `Admission_Time__c`), `Last_Admission_Date__c`(MAX,
`Admission_Time__c`)를 **Roll-Up Summary**로 전환한다 — 이 3개 필드를 갱신하던
별도의 집계 Flow는 더 이상 만들지 않는다.

단, Master-Detail 관계는 **부모(`Attendance_Record__c`)가 먼저 존재해야 자식
(`Admission__c`)을 만들 수 있다**는 제약이 있다. 이를 위해 Welcome Campaign
Flow(Person Account 생성 트리거)에 `Attendance_Record__c` 1건 생성 단계를 추가한다
— 별도 Flow로 분리하지 않고 같은 트리거(Account 생성)에 통합한다(Flow를 2개 두면
실행 순서까지 신경 써야 해서 오히려 복잡해진다).

`Attendance_Record__c`에는 기존과 동일하게 `Fan__c` 기준 팬당 1건 Duplicate Rule을
유지한다(Matching Rule: `Fan__c` Exact, Action on Create = Block).

### 이유

- Roll-Up Summary는 Master-Detail 관계에서만 만들 수 있다 — Lookup을 유지하면서
  "자동 집계"를 얻을 방법이 없다.
- Master-Detail 자식은 부모의 Sharing 설정을 그대로 상속한다 — 별도 공유 규칙을
  추가로 설계할 필요가 없어진다.
- Attendance_Record__c 생성을 Welcome Campaign Flow에 통합한 이유는, Account
  생성이라는 같은 트리거에 Flow를 여러 개 걸어두면 실행 순서 보장이 새로운 문제로
  등장하기 때문이다 — 이미 있는 Flow에 단계 하나를 추가하는 편이 더 단순하다.

### 영향

- `03_SYSTEM.md` §2(Admission__c, Attendance_Record__c): `Attendance_Record__c`
  Master-Detail 필드 추가, 집계 3필드를 Roll-Up Summary로 변경.
- `03_SYSTEM.md` §3(ERD): `Admission__c` → `Attendance_Record__c` Master-Detail
  관계를 명시적으로 추가한다.
- `03_SYSTEM.md` §4.4(Welcome Campaign Flow): `Attendance_Record__c` 1건 생성 단계를
  다이어그램에 추가한다.
- `03_SYSTEM.md` §4.2(Trigger → Action 매핑): "First Visit Guide" 트리거를
  `Attendance_Record__c` 존재 여부 확인 대신 `Total_Admissions__c`(Roll-Up) = 1로
  판별하도록 갱신한다.
- `03_SYSTEM.md`에 Duplicate Rule 섹션을 신설해 이 규칙을 명문화한다(기존에는 문서에
  규칙 자체가 없었다).

---

## Decision 013 — Order에 Payment_Status__c/Refund 필드 추가, Membership_End_Date__c를 Coverage_Start/End_Date__c로 통합

**상태**: 확정
**기록일**: 2026-08-11

### 배경

Cloud Alpacas는 티켓·시즌권·멤버십·굿즈 4종을 판매하는데, 구매 이후 상태 변화(취소·
환불)를 기록할 곳이 없었다. 또한 `Membership_End_Date__c`는 이름 그대로 Membership
전용으로 만들어졌지만, 실제로는 Season Pass(시즌권)도 같은 성격의 "적용 기간"이
필요해서 이름이 좁았다.

### 결정

**1. `Order`에 결제/환불 상태 필드를 추가한다.**

| Field (API Name) | 타입 | 설명 |
|---|---|---|
| `Payment_Status__c` | Picklist (Paid/Cancelled/Refunded) | 표준 `Status`(Draft/Activated)와는 **다른 축** — 결제/환불 상태를 표현한다. |
| `Refund_Date__c` | Date | 환불 처리일. |
| `Refund_Reason__c` | Picklist (단순변심/상품불량/경기취소/일정변경) | 환불 사유. |

**2. `Membership_End_Date__c`를 삭제하고, `Coverage_Start_Date__c`/
`Coverage_End_Date__c`(Date)로 대체한다.** 멤버십과 시즌권이 공통으로 쓰는 "적용
기간" 필드로 통합한다.

**3. MVP는 Order 전체 단위 환불만 지원한다.** 부분 환불(OrderItem 단위 환불)은
Future Scope로 남긴다.

**4. 환불 문의는 기존 `Case.Related_Order__c`로 Order와 연결한다** — 이미 존재하는
필드이므로 새 필드를 추가하지 않는다.

**5. `Fan_Activity_Pattern__c.Total_Spend__c` 계산 시 `Payment_Status__c` =
Refunded/Cancelled인 Order는 집계에서 제외한다.** 다만 이 집계를 **누가/언제**(Flow
또는 Apex) 계산하는지는 이번에 확정하지 않는다(TBD) — `03_SYSTEM.md` §4.6에 이미
있는 "아직 정의되지 않은 Trigger" 목록과 같은 방식으로 미정 상태를 문서화한다.

### 이유

- `Payment_Status__c`를 표준 `Status`와 분리한 이유는 Decision 009·010에서 이미
  적용한 원칙("서로 다른 개념을 같은 필드/이름으로 섞지 않는다")과 같다 — Order가
  Draft/Activated인지와, 결제가 Paid/Refunded인지는 독립된 질문이다.
  `Order.Status`(Draft에서만 Product 추가 가능)와 `Payment_Status__c`(결제 이후의
  상태)는 시점부터 다르다.
- 부분 환불을 지금 지원하지 않는 이유는, 한 Order에 OrderItem이 여러 개(예: 티켓
  2장) 있을 때 그중 1개만 환불하는 케이스까지 지원하려면 필드를 OrderItem에 둬야
  하는데, 이는 지금 팀 규모와 Demo 범위에서 필요한 복잡도를 넘어선다(CLAUDE.md §5
  MVP 원칙).
- `Coverage_Start/End_Date__c`로 이름을 바꾼 이유는, 필드명만 보고도 "멤버십과
  시즌권이 공통으로 쓴다"는 걸 알 수 있게 하기 위해서다 — Decision 010이
  `Fan_Value_Tier__c`에 적용한 것과 같은 원칙(필드명이 스스로 용도를 설명해야 한다).

### 영향

- `03_SYSTEM.md` §2(Order): `Membership_End_Date__c` 삭제, `Coverage_Start_Date__c`/
  `Coverage_End_Date__c`/`Payment_Status__c`/`Refund_Date__c`/`Refund_Reason__c` 추가.
- `03_SYSTEM.md` §2(Fan_Activity_Pattern__c): `Total_Spend__c` 설명에 "Refunded/
  Cancelled Order 제외" 규칙을 추가한다.
- `03_SYSTEM.md` §4.6: `Total_Spend__c` 계산 주체(Flow/Apex 미정)를 기존 표에
  항목으로 추가한다.
- `03_SYSTEM.md` §5(Future Scope): 부분 환불(OrderItem 단위)을 Future Scope
  항목으로 추가한다.

---

## Decision 014 — Fan Profile은 원천 데이터를 Account에 중복 저장하지 않고 Related List로 참조

**상태**: 확정
**기록일**: 2026-08-11

### 배경

Fan Profile 화면에 "최근 관람일, 총 관람 횟수, 총 구매금액, 구매 빈도, 최근 활동일"을
보여줘야 하는데, 이 값들을 Account(Person Account)의 새 필드로 또 만들 것인지, 아니면
이미 있는 원천 Object(`Attendance_Record__c`, `Fan_Activity_Pattern__c`, `Order`,
`Engagement_Signal__c`)를 화면에서 그대로 참조할 것인지 결정이 필요했다.

### 결정

Fan Profile이 보여주는 아래 항목은 **Account 필드로 복제하지 않고, 원천 Object를
Related List/Lightning Component로 그대로 참조**한다.

| 표시 항목 | 원천 Object | 원천 필드 |
|---|---|---|
| 최근 관람일 / 총 관람 횟수 | `Attendance_Record__c` | `Last_Admission_Date__c` / `Total_Admissions__c` |
| 총 구매금액 | `Fan_Activity_Pattern__c` | `Total_Spend__c` |
| 구매 빈도 | `Order` | (Fan 기준 Order 건수) |
| 최근 활동일 | `Engagement_Signal__c` | `Signal_Date__c`(최신 1건) |

반면 `Current_Segment__c`/`Engagement_Level__c`/`Engagement_Score__c`/
`Fan_Value_Tier__c`는 원천 복제가 아니라 **Fan 자체의 상태값**이므로 지금처럼
Account에 직접 저장한다(Decision 009·010과 변경 없음).

### 이유

- 위 4개 항목은 각각 이미 자기 Object(Attendance Record, Fan Activity Pattern,
  Order, Engagement Signal)에 원본이 존재한다 — Account에 또 필드를 만들면 원본이
  바뀔 때마다 두 곳을 동기화해야 하는 불필요한 자동화가 늘어난다.
- 반대로 Current Segment/Engagement Level/Fan Value는 여러 원천을 종합한 "판단
  결과"이지 특정 Object의 단순 복제값이 아니다 — 이 값들은 원본이 따로 없으므로
  Account에 두는 것이 캐시가 아니라 원래 자리다(§2.1의 "왜 캐시와 이력을 나누나"
  설명과 같은 원칙).

### 영향

- `03_SYSTEM.md`에 "Fan Profile 설계 원칙" 섹션을 신설해 위 표를 그대로 반영한다.
- `04_DEMO.md` §4 Fan Profile 화면 설명이 이 원칙(원천 참조 vs Account 직접 저장)을
  따르는지 이후 확인이 필요하다(이번 갱신 범위 밖).

---

## Decision 015 — [P2] Phase 2 B2B Business Workflow 및 핵심 개념 도입

**상태**: 확정
**기록일**: 2026-08-15

### 배경

Phase 1(B2C Fan 360 MVP)이 2026-08-14 Demo로 완료되고, Phase 2(MVP 고도화 + B2B
Collaboration/Sponsorship Expansion)가 시작되면서 `00_STORY.md` §8/§9와
`01_PROJECT.md` §2.7/§8이 Fan 360 데이터를 구단의 B2B 의사결정에 활용하는 Business
Workflow를 새로 정의했다. 이 내용은 프로젝트 전체 범위에 영향을 주는 변경
(CLAUDE.md §7)이므로 Decision으로 공식 기록한다.

### 결정

1. Phase 1에서 구축한 Fan 360 데이터를 Phase 2 B2B Collaboration/Sponsorship
   의사결정의 입력으로 활용한다.
2. 다음 Business Workflow를 Phase 2의 공식 Workflow로 채택한다.

   > Fan Insight → Business Fit 가설 → Candidate Discovery → Lead →
   > Account/Contact → Opportunity → Collaboration → Performance/Evaluation →
   > Partnership/Sponsorship

3. **Lead**는 아직 관계가 형성되지 않은 잠재 기업/후보를 관리하는 Business
   개념으로 정의한다. 단, Salesforce Standard Lead Object를 사용할지는 아직
   확정하지 않는다.
4. **Proposal**은 Lead를 대체하는 개념이 아니다. Opportunity 단계에서 발생하는
   제안/제안서의 Business 개념으로 위치를 명확히 한다(기존 §2.6·§6.1 정의는
   그대로 유지한다). 단, Salesforce에서 별도 Object로 만들지 Opportunity에
   흡수할지는 TBD.
5. **Collaboration**은 장기 Partnership/Sponsorship 이전에 성과를 검증하기
   위한 단기 실행 단계로 정의한다. 단, Campaign으로 구현할지 별도 Object로
   구현할지는 TBD.

### 이유

- Fan 360 없이 B2B 영업을 하면 "유명한 회사에 무작정 제안하는" 방식으로
  되돌아간다(`00_STORY.md` §8.2) — Fan 360을 입력으로 삼는 것은 선택이 아니라
  Phase 2가 존재하는 이유 자체다.
- Lead 개념이 필요한 이유는 B2B 영업이 본질적으로 "후보 다수 → 소수만 실제
  전환되는" 깔때기 구조이기 때문이다 — Fan(B2C)처럼 "가입 = 관계 시작"이
  아니다(`01_PROJECT.md` §6.11).
- Proposal을 Lead와 분리한 이유는, 기존 §2.6 Workflow가 이미 "접촉이 있는
  상대에게 제안하는" 상황을 전제했기 때문이다 — 이 정의를 바꾸지 않고, 그
  앞에 빠져 있던 단계(Lead)만 새로 추가하는 것이 기존 결정과 충돌하지 않는
  방법이다.
- Collaboration을 별도 개념으로 도입한 이유는, 검증되지 않은 상대와 곧바로
  장기 계약을 맺는 리스크를 줄이기 위해서다(`00_STORY.md` §8.3). Object 구현
  여부를 지금 확정하지 않는 이유는, Decision 003의 "Standard First, Custom
  When Needed" 판단을 이번에도 `03_SYSTEM.md` 단계에서 실제 후보 수·업무량을
  보고 내리는 것이 안전하기 때문이다.

### 영향

- `00_STORY.md` §8/§9, `01_PROJECT.md` §2.7/§4/§5/§6.11/§8은 이미 이 Decision의
  내용을 반영하고 있다 — 이 Decision은 새 내용을 만드는 것이 아니라 두 문서에
  서술된 것을 공식 기록으로 확정하는 것이다.
- `03_SYSTEM.md`는 이 Decision 이후 Lead/Proposal/Collaboration의 실제
  Salesforce Object/Field를 설계한다.

### TBD (아직 확정하지 않은 것)

- Lead의 Salesforce 구현 방식(Standard Lead vs 비활성 Account)
- Collaboration의 Salesforce 구현 방식(Campaign 재사용 vs 별도 Object)
- Proposal의 Salesforce 구현 방식(Opportunity 흡수 vs 별도 개념)
- B2B 성과 측정에 사용할 구체적인 Fan 360 데이터/필드
- Collaboration 성과가 기대에 못 미칠 경우의 재검토/종료 기준

---

## Decision 016 — [P2] Decision 005 Future Scope 중 Phase 2 승격 범위 재확인

**상태**: 확정
**기록일**: 2026-08-15

### 배경

Decision 005는 "Sponsorship/Partnership Domain 전체를 Phase 1 MVP 구현 범위에서
제외"했다. Phase 2가 시작되면서 이 Future Scope 중 일부를 다시 다뤄야 하는데,
Decision 005 자체를 수정하면 "그때 결정이 틀렸다"는 뜻으로 오해될 수 있다 — 이를
방지하기 위해 시간적 맥락을 명확히 하는 별도 Decision을 남긴다.

### 결정

- Decision 005는 Phase 1 MVP 범위에 대한 결정이므로 수정하지 않는다.
- Phase 1에서 제외했던 Sponsorship/Partnership 영역 중 **Sponsor / Partner /
  Partner Contact / Sponsorship Package / Sponsor Contract** 등의 Business
  개념을 Phase 2에서 다시 활용한다(`01_PROJECT.md` §2.6·§4·§5·§8).
- 이것은 Decision 005를 번복하는 것이 아니라, Phase 1에서 제외했던 영역을
  Phase 2의 확장 범위로 **승격**하는 것이다.
- 실제 Salesforce Object/Field/Relationship 구현 범위는 이후 `03_SYSTEM.md`에서
  결정한다.

### 이유

- Decision 005가 내려진 시점(2026-08-06)에는 Demo가 팬 개인의 여정(김매니저 ↔
  이루키)에만 초점이 있었고, 스폰서십은 그 여정에 등장하지 않았다 — 그 판단은
  **그 시점 범위**에서 옳았다. Phase 2에서 B2B가 새 Business Goal(CLAUDE.md §2)로
  추가된 것이지, Decision 005 당시의 판단이 잘못됐던 것이 아니다.
- "제외 → 승격"이라는 표현을 쓰는 이유는, Decision 005가 이미 남겨둔 Future
  Scope 목록(`01_PROJECT.md` §4의 Partnership Domain Entity)을 그대로 재사용할
  수 있기 때문이다 — 처음부터 다시 설계할 필요가 없다.

### 영향

- `03_SYSTEM.md` §0-1 MVP Implementation Matrix와 §5 Future Scope의
  "Sponsor/Partner 전체 Object군" 항목은, 이제 "영구 제외"가 아니라 "Phase 2에서
  다시 설계할 대상"이라는 성격으로 바뀐다 — 다만 이 Decision은 `03_SYSTEM.md`를
  직접 수정하지 않으며, 실제 반영은 이후 `03_SYSTEM.md` 개정 작업에서 이루어진다.
- Decision 005 본문은 이 Decision이 참조만 할 뿐 어떤 문구도 변경하지 않는다.

---

## Decision 017 — [P2] Business Decision: Agentforce AI Matching을 Phase 2 범위로 예외 편입 (CLAUDE.md §5 Future Scope 갱신)

**상태**: 확정
**기록일**: 2026-08-18

### 배경

`CLAUDE.md` §5는 "Marketing Cloud, Data Cloud, Agentforce... 등은 Phase 2 범위에도
포함하지 않으며 Future Scope로 관리한다"고 명시하고 있었고, `03_SYSTEM.md` §7.2 B·§7.3도
이 원칙을 그대로 따라 "Agentforce 기반 실제 AI Matching은 CLAUDE.md §5 Future Scope이며
화요일 회의에서도 논의 대상이 아니다"라고 Draft 단계에 못박아뒀다(`docs/decision_sheet/
P2_TECHNICAL_DECISION_SHEET.md`도 동일하게 "Option C: Agentforce는 이번 결정 대상
아님"이라고 사전에 명시). 그런데 2026-08-18 Technical Decision 회의에서 팀은 B2B
Candidate 발굴의 AI Matching을 **Agentforce로 구현하기로 결정**했다 — 이는 기존
CLAUDE.md의 명시적 범위 제한과 정면으로 충돌하는 결정이므로, 이 Decision으로 별도
기록해 CLAUDE.md의 Future Scope 원칙 자체를 좁은 범위에서 갱신한다.

### 결정

1. **CLAUDE.md §5 Future Scope에서 Agentforce를 전면 제외하지 않는다.** 원칙은
   유지하되, **B2B AI Matching(Segment Match·Recommendation Reason 자동 생성
   포함)에 한해 예외적으로 Phase 2 범위에 포함**한다.
2. 이 예외는 좁게 적용한다 — Agentforce의 다른 활용(예: Decision 008이 언급한 Fan
   Summary, Next Best Action 설명 등)은 여전히 Future Scope다. Decision 008 본문은
   수정하지 않는다.
3. AI Matching Agentforce 구현은 혜준 파트(자동화 구현 영역)가 담당한다.
4. **"Agentforce를 실제로 어떤 방식으로 구성하는가"(프롬프트, 데이터 소스, 평가
   기준 등)의 상세 기술 설계는 이 Decision이 확정하지 않는다(TBD)** — 이 Decision은
   "Agentforce를 쓴다"는 범위·방향만 확정하며, 실제 구성은 `03_SYSTEM.md`에서 추가로
   설계한다.
5. Demo에서 Sanrio(산리오)가 자연스럽게 후보로 도출되려면, Scenario/Dummy Data가
   Fan Insight와 Business Fit 가설(`00_STORY.md` §8.3)을 충분히 뒷받침해야 한다 —
   이는 Agentforce 자체의 정확도가 아니라 데이터 설계의 책임이다.

### 이유

- CLAUDE.md §7은 "AI가 다른 제안을 하더라도 공식 문서(Source of Truth)가 우선"이라고
  명시한다 — 그런데 이번에는 반대로 **팀의 공식 의사결정(화요일 회의)이 기존 공식
  문서(CLAUDE.md)의 범위 제한과 충돌**하는 상황이었다. 이런 경우 문서를 몰래 어기지
  않고, CLAUDE.md 자체를 예외 조항과 함께 갱신하고 그 근거를 Decision으로 남기는
  것이 "문서 간 충돌 없음"이라는 원칙(CLAUDE.md §7)에 맞는 처리 방식이다.
- 예외를 "AI Matching"으로 좁게 한정한 이유는, CLAUDE.md §5의 Future Scope 원칙
  자체(Marketing Cloud/Data Cloud/외부 API 연동 등을 지금 벌이지 않는다)가 여전히
  유효하기 때문이다 — 이번 결정이 "Agentforce는 이제 전부 써도 된다"는 뜻으로
  오해되지 않도록, 범위를 명확히 좁혀 기록한다.
- 상세 기술 설계를 TBD로 남긴 이유는, "Agentforce를 쓴다"는 방향 결정과 "어떻게
  구성하는가"라는 구현 결정은 서로 다른 질문이기 때문이다 — Decision 015가
  Lead/Collaboration의 Object 여부와 상세 Field를 분리했던 것과 같은 원칙이다.

### 영향

- `CLAUDE.md` §5 Future Scope 문단이 이 Decision을 근거로 갱신됐다 — "Agentforce는
  원칙적으로 Future Scope이나, B2B AI Matching에 한해 예외"라는 문구를 추가했다.
- `03_SYSTEM.md` §7.2 B(AI Matching)·§7.2 H(Segment Match)·§7.2 I(Recommendation
  Reason)·§7.3(Future Scope)이 이 Decision을 근거로 "확정" 상태로 갱신됐다.
- Decision 008 본문(Agentforce를 은영의 장기 역할로만 남기고 Fan Summary 등은
  Future Scope로 분류한 결정)은 수정하지 않는다 — 그 결정은 여전히 유효하며, 이
  Decision은 그 예외를 AI Matching 범위에서만 추가하는 것이다.

### TBD (아직 확정하지 않은 것)

- Agentforce AI Matching의 실제 기술 구성(프롬프트, 참조 데이터, 평가/검증 방식)
- Segment Match·Recommendation Reason이 Agentforce로부터 실제로 어떻게 값을
  받아오는지(Flow/Apex 연동 방식)

---

## Decision 018 — [P2] Technical Decision: Phase 2 B2B Technical Decision Sheet A~K 확정

**상태**: 확정 (K 항목은 보류)
**기록일**: 2026-08-18

### 배경

`03_SYSTEM.md` §7.2는 2026-08-15 시점에 Wireframe과 Business 분석을 근거로 11개
항목(A~K)을 Draft로 남겨두고 "화요일 팀 회의에서 논의 후 Technical Decision으로
확정한다"고 예고했다(Decision 015·016 이후 이어지는 작업). 2026-08-18(화요일) Phase 2
Technical Decision 회의에서 이 11개 항목을 모두 논의했고, K를 제외한 10개 항목을
확정했다. B(AI Matching)는 "Agentforce를 Phase 2 범위에 포함해도 되는가"라는
CLAUDE.md 범위 제한과 직결된 질문이라, 그 **범위 승인**은 Business Decision으로
분리해 [[Decision 017]]에 별도 기록했다. 이 Decision(018)은 B를 포함해 A~K
전체의 **기술 구현 선택**(무엇을 골랐는가)을 한 표에 모아 기록한다 — 두 Decision은
같은 B를 다른 질문("써도 되는가" vs "무엇을 골랐는가")으로 다룰 뿐, 서로 다른 내용을
중복 기록하지 않는다.

### 결정

| ID | 결정 항목 | 확정 내용 | 비고 |
|---|---|---|---|
| A | Partner Candidate | **Lead로 흡수** — 별도 Custom Object(`Partner_Candidate__c`) 없음. Lead Status를 세분화해 Candidate 단계까지 표현(Candidate → Lead → Qualified/후속 단계 → Conversion → Account/Contact → Opportunity) | 정확한 Status Picklist Label은 TBD |
| B | AI Matching | **Agentforce**로 구현 — Rule-based/Demo Sample 대신 채택 | 범위 승인(왜 Agentforce를 써도 되는지)은 [[Decision 017]] 참고 — 이 표는 "무엇을 선택했는지"만 기록한다. 상세 구현 TBD |
| C | Quote | **Standard Quote(Quote + QuoteLineItem) 사용** — Custom Object 아님 | Sponsorship Package(Product2) 확정이 선결 조건이었으며 이미 충족됨(§7.1) |
| D | Campaign vs Collaboration | **Campaign의 Record Type**으로 구현 — 별도 `Collaboration__c` Custom Object 없음 | Draft 시점 추천(단순 Lookup 필드)과 다른 방향으로 결정 |
| E | Lead Score | 신규 `Lead_Score__c`(Number) 필드 신설 — 표준 `Rating`은 원래 목적대로 유지 | 정확한 Type/값 범위는 Org 반영 시 확정 |
| F | Expected Benefit | 개별 필드 3개(단기/중기/장기)로 분리 | 정확한 API Name은 미확정(TBD), 임의 확정 금지 |
| G | Target Segment | Picklist로 구현 | 실제 Picklist 값 목록은 미확정(TBD) |
| H | Segment Match | **Agentforce Matching**으로 구현([[Decision 017]]과 연동) | 상세 구현 TBD |
| I | Recommendation Reason | 자동 생성 Long Text([[Decision 017]]의 Agentforce Matching 결과 근거)로 구현 | 상세 구현 TBD |
| J | Fan Insight / Fan Grouping 화면 | 기존 방향(Option A) 유지 — Standard Report + Report Type + Dashboard, 별도 Custom Object 없음 | Draft 시점 추천과 동일한 방향으로 확정 |
| K | Account 집계 필드(`Active Collaboration`/`Total Collaboration Value`) | **보류(On Hold)** — Option A(Roll-up)/B(Report) 어느 쪽도 확정하지 않음 | Opportunity-Account Roll-up 가능 여부 기술 확인 후 재논의 |

### 이유

- A(Lead 흡수)는 Decision 003의 "Standard First, Custom When Needed" 원칙을 그대로
  적용한 결과다 — Candidate와 Lead가 별도 생명주기를 가져야 할 근거가 이번 회의
  시점에는 확인되지 않았다.
- D(Campaign Record Type)는 Draft 시점의 추천(단순 Lookup 필드)을 뒤집은 결정이다
  — B2C/B2B Campaign을 화면·리스트에서 분리해서 볼 필요가 실제로 있다고 팀이
  판단했기 때문이다(정확한 근거는 회의록 별도 보관, 이 문서는 결과만 기록한다).
- E(Lead Score)는 정성적 표준 `Rating`과 정량적 점수를 같은 필드에 섞지 않는다는
  Decision 009·010의 원칙을 그대로 이어받은 결정이다.
- F(Expected Benefit 3분할)·G(Target Segment Picklist)·J(Fan Insight Report/
  Dashboard)는 모두 Draft 시점의 추천과 동일한 방향으로 확정됐다 — 이번 회의는
  기존 분석이 타당했음을 재확인한 것에 가깝다.
- K를 보류한 이유는, Opportunity-Account가 표준 Lookup 관계라 Roll-up Summary
  자체가 기술적으로 가능한지 확인되지 않았기 때문이다 — 확인 없이 Option A를
  확정하면 나중에 되돌려야 할 위험이 있다(CLAUDE.md §5 MVP 원칙 — 확정하지 않은
  것을 확정된 것처럼 만들지 않는다).

### 영향

- `03_SYSTEM.md` §7.1·§7.2(A~K)·§7.3이 이 Decision을 근거로 "DRAFT — NOT FINAL"에서
  "CONFIRMED"(K는 "ON HOLD")로 갱신됐다.
- `01_PROJECT.md` §4(Lead/Collaboration Entity 설명)·§6.11(TBD 목록)·§8.1(Business
  Workflow 표)·§8.3이 A·D의 확정 내용을 반영해 갱신됐다.
- `04_DEMO.md` §7~§9·§12가 이 표를 근거로 Scene 목록의 ⭐️ 표시를 정리하고, 8/21
  구현 범위(Fan Insight → Collaboration 시작까지)와 Future Scope(Performance·KPI·
  재검토/종료·장기 전환)를 명확히 구분했다.
- `docs/decision_sheet/P2_TECHNICAL_DECISION_SHEET.md`는 회의용 Working Document이며
  Source of Truth가 아니므로(문서 자체 §5) 이 Decision이 공식 기록이다 — 그 문서는
  수정하지 않는다.

### TBD (아직 확정하지 않은 것)

- Lead Status의 정확한 Picklist Label(Candidate 단계 표현 방식)
- `Lead_Score__c`의 정확한 Type/값 범위/계산 방식
- Expected Benefit 3개 필드의 정확한 API Name
- Target Segment Picklist의 실제 값 목록
- Segment Match·Recommendation Reason의 Agentforce 상세 구현([[Decision 017]] TBD와 동일)
- Account 집계 필드(K) 전체 — Option A/B 모두 미확정

---

## Decision 019 — [P2] Business Decision: B2B Story 축을 "Collaboration 중심"에서 "Sponsorship Sales/Pipeline 중심"으로 전환 (d'Alba 대표 시나리오, 기업 DB, Fan Fit/Lead Score 구분, Fan Data 목표 5,000명)

**상태**: 확정
**기록일**: 2026-08-18

### 배경

Decision 015~018이 확정한 "Fan Insight → Business Fit → Candidate Discovery → Lead →
Account/Contact → Opportunity → 단기 Collaboration → 성과 검증 → 장기 Partnership"
흐름과, 이 흐름의 대표 예시로 써온 산리오(Sanrio) Hello Kitty Collaboration 시나리오는
**2026-08-18 멘토링**을 통해 Business 관점에서 크게 조정이 필요하다는 피드백을 받았다.
핵심 지적은 다음과 같다.

- "Collaboration을 잘할 기업을 찾는다"는 프레이밍은 실제 구단의 Pain Point(재정
  적자)를 해결하는 목적어가 명확하지 않다 — 진짜 목적은 "광고비/스폰서십 비용을
  지불할 가능성이 높은 기업을 발굴해 실제 매출(Revenue)로 연결하는 것"이다.
- 과거 실패 원인을 "장기 계약을 데이터 없이 시작했다"는 정도로만 설명했는데,
  실제로는 "야구 팬은 40~50대 남성"이라는 구체적으로 틀린 타깃 가정이 있었다 —
  이 구체성이 Fan 360 데이터 기반 접근의 필요성을 훨씬 설득력 있게 만든다.
- Lead를 둘러싼 점수 체계에서 "Agentforce가 매긴 점수"와 "영업 담당자가 실제
  계약 가능성을 판단하는 점수"가 문서마다 섞여 쓰이고 있었다 — 이 둘은 근거와
  산출 시점이 전혀 다른 별개의 개념인데도 구분 없이 "Score"로만 표현됐다.
- 기존 100명 이하 소규모 Fan Dummy Data로는 Fan Segment/기업 Matching/Scoring의
  분포를 통계적으로 설득력 있게 보여줄 수 없다는 멘토 피드백을 받았다.
- 산리오는 실존 기업이지만 Cloud Alpacas의 Fan 360(뷰티/라이프스타일/F&B 관심)과의
  연결 논리가 약했다 — 더 명확한 산업 연결고리를 가진 대표 시나리오가 필요했다.

### 결정

1. **B2B Business Story의 핵심 메시지를 "팬을 이해하고, 기업을 찾아, 계약으로
   연결하다"로 전환한다.** 흐름은 다음과 같이 확장된다:
   > Fan 360 → Fan Insight(팬덤의 광고 가치 발견) → 기업 DB(약 100개) →
   > Agentforce Matching/Top 10 추천 → Outbound Lead → Lead Qualification/Lead
   > Score → Account/Contact → Opportunity → Sponsorship Package/Quote →
   > Negotiation → Closed Won → Contract/Sponsorship Revenue → Pipeline/Revenue
   > Dashboard
2. **과거 실패 배경을 구체화한다**: "야구 팬은 40~50대 남성"이라는 검증되지 않은
   타깃 가정으로 과거 장기 스폰서·캠페인을 진행했으나 기대만큼 성과가 나지
   않았다는 것이 Pain Point의 구체적 근거다(`00_STORY.md` §2 Pain Point 7).
3. **대표 Demo 시나리오를 산리오(Sanrio/Hello Kitty)에서 d'Alba(달바)로 교체한다.**
   d'Alba는 기업 DB(약 100개) 중 Agentforce가 높은 Fit으로 추천하는 대표 광고주이며,
   이후 Outbound Lead → Account/Contact → Opportunity → Sponsorship 계약으로
   이어지는 대표 Scenario로 쓴다. 기존 문서에 남아 있는 Sanrio 언급은 이 Decision
   이전의 역사적/예시 맥락(예: 초기 Domain Model 분석, 확정된 과거 Draft 인용)에
   한해 보존하고, 현재形 대표 시나리오로는 더 이상 사용하지 않는다.
4. **기업 DB(약 100개)를 새로운 Business 개념으로 도입한다.** 가상의 기업만 생성하지
   않고 실제 기업 정보를 기반으로 구성하며, 데이터 출처로 DART Open API 활용을
   방향으로 검토한다(TBD — 실제 연동은 확정하지 않는다). 화장품/뷰티, F&B, 자동차,
   핀테크, OTT 등 다양한 산업의 기업이 포함된다. **이 기업 DB를 Salesforce에서
   어떤 Object 형태로 관리할지는 확정하지 않는다(TBD)** — 임의로 새 Custom
   Object/Field를 만들지 않는다.
5. **Fan Fit/Recommendation Score(Agentforce)와 Lead Score를 명확히 다른 개념으로
   구분한다.**
   - Fan Fit/Recommendation Score = Agentforce가 Fan 360 데이터를 근거로 산출하는
     "팬덤과 기업의 궁합" 값(Target Segment, Segment Match, Recommendation Reason 포함)
   - Lead Score = 담당자의 의사결정 권한, 직무/역할, 접촉 이력, 메시지/미팅 반응,
     예산/구매 가능성 등 **실제 영업 활동**을 근거로 판단하는 "계약 가능성" 값
   - 이 구분은 새로운 Object/Field 결정이 아니라 **기존 Decision 018-E
     (`Lead_Score__c`)·018-H(Segment Match)·018-I(Recommendation Reason)의 의미를
     명확히 하는 것**이다 — 기술 선택(어떤 Object/Field를 쓰는지)은 바뀌지 않는다.
6. **Fan Dummy Data 목표를 기존 "약 1,000명"에서 "최소 5,000명"으로 상향한다.**
   100명 이하 소규모 데이터로는 Fan Segment/기업 Matching/Scoring의 분포를 설득력
   있게 보여줄 수 없다는 멘토 피드백을 반영한다. 실제 5,000명 CSV 생성/Org
   Insert는 이 Decision이 확정하는 것이 아니라 별도 Data 작업이다 — "목표
   데이터 규모"와 "구현 완료 여부"를 구분한다.
7. **B2B Sales Pipeline/Revenue라는 새로운 관점을 도입한다.** 현재 Opportunity 수,
   Pipeline Amount, Stage별 Pipeline, 예상 매출, 목표 매출, 목표 대비 부족 금액,
   평균 계약금액 기준 필요 신규 스폰서 수 등을 Pipeline/Revenue Dashboard로 보여주는
   방향을 잡는다. **구체적인 KPI 공식/Field는 확정하지 않는다(TBD)** — 임의의
   계산식을 확정하지 않는다.

### 이 Decision이 바꾸지 않는 것 (Decision 017·018과의 관계)

- **Decision 017(Agentforce = Phase 2 AI Matching 예외)은 그대로 유지한다.** 오히려
  이번 Decision은 Agentforce의 역할(기업 DB Matching)을 더 구체화한다.
- **Decision 018의 A~K 기술 선택은 전부 그대로 유지한다**: Partner Candidate → Lead
  흡수(A), Standard Quote(C), Campaign = Collaboration Record Type(D), `Lead_Score__c`
  신규 필드(E), Expected Benefit 3분할(F), Target Segment Picklist(G), Fan Insight
  = Report/Dashboard(J), Account 집계 On Hold(K) — 어느 것도 뒤집지 않는다. 바뀐
  것은 이 기술 요소들이 표현하는 **Business Story의 중심**이다.
- **Collaboration 개념 자체는 삭제되지 않는다.** Campaign Record Type으로 여전히
  유효하며, Opportunity Won 이후 실행 수단으로 쓰일 수 있다 — 다만 Phase 2를
  대표하는 중심 개념의 자리에서는 내려온다.
- Decision 001~016의 역사적 기록은 수정하지 않는다.

### 이유

- Business Goal(CLAUDE.md §2 — Fan Lifetime Value·구단 수익 다변화)에 더 직접적으로
  연결되는 것은 "Collaboration 실행"이 아니라 "실제 계약과 매출"이다 — Sales
  Pipeline/Revenue 프레이밍이 이 목표와 더 명확히 정렬된다.
- "40~50대 남성"이라는 구체적 오판 사례를 Pain Point에 명시하면, Fan 360 데이터
  기반 접근이 왜 필요한지가 추상적 설명("데이터 없이 시작했다")보다 훨씬
  설득력 있게 전달된다.
- Fan Fit Score와 Lead Score를 분리하지 않으면, "Agentforce가 추천했으니 곧 계약될
  것"이라는 잘못된 기대를 만들 위험이 있다 — 실제 영업은 추천 이후에도 별도의
  단계(Qualification)를 거쳐야 한다는 것을 Business/System 문서 모두에서 명확히
  해야 한다.
- Fan Data 규모를 5,000명으로 올린 이유는 순수하게 Demo 설득력 문제다 — 세그먼트
  분포, 기업 Matching 결과, Scoring 분포 모두 표본이 작으면 "우연"처럼 보인다.
- d'Alba를 대표 시나리오로 쓰는 이유는 뷰티/스킨케어 산업이 Fan Insight가 발견한
  "여성 팬의 뷰티/라이프스타일 관심"과 직접 연결되어, "왜 이 기업인가"라는 질문에
  산리오보다 더 명확하게 답할 수 있기 때문이다.

### 영향

- `00_STORY.md` §1, §2, §3, §4, §8, §9가 이 Decision을 근거로 전면 갱신됐다 —
  Business Goal, Pain Point, Persona Mission, B2B Story, Next Best Action 표.
- `01_PROJECT.md` §2.7, §4(Lead/Collaboration Entity), §5([P2] Partnership 축),
  §6.1(매핑 표), §6.11, §8(Business Workflow 표)이 이 Decision을 근거로 갱신됐다.
- `03_SYSTEM.md` §7 배너·§B·§E·§H·§I·§K에 Agentforce Fit Score ≠ Lead Score 구분과
  기업 DB 개념이 반영됐다 — A~K의 기술 선택 자체(Status 줄)는 변경하지 않았다.
- `04_DEMO.md` §7~§9·§12가 Scene 흐름을 d'Alba/Sponsorship Sales Pipeline 기준으로
  갱신했고, Fan Data 목표를 5,000명으로 갱신했다.
- `docs/decision_sheet/P2_TECHNICAL_DECISION_SHEET.md`, `data/DEMO_DATA_STANDARD.md`,
  `data/P2_DUMMY_DATA_MASTER.md`, `docs/decision_sheet/P2_DATA_CONTRACT.md`,
  `02_TEAM_GUIDE.md`, `docs/members/*.md`도 이 Decision을 근거로 갱신했다(각 문서의
  변경 내역 참고).

### TBD (아직 확정하지 않은 것)

- ~~기업 DB(약 100개)의 Salesforce Object 구현 형태~~ → **2026-08-19 [[Decision 020]]으로 해소**(Object 아님, External Input/Data Source로 확정)
- 기업 데이터 출처(DART Open API 등) 실제 연동 여부
- Pipeline/Revenue Dashboard의 구체적인 지표·계산식(목표 매출, 필요 신규 스폰서 수 등)
- Fan Dummy Data 5,000명의 실제 분포 비율, CSV 생성/Org Insert 일정
- `Lead_Score__c`의 실제 계산 방식(사람이 수동 입력하는지, 일부 자동화하는지)

---

## Decision 020 — [P2] Technical Decision: 기업 DB(약 100개)는 Salesforce Object가 아니다 — DART Open API 기반 구조 + Top 10 Recommendation 단계 명시

**상태**: 확정
**기록일**: 2026-08-19 (같은 날 내 갱신 — 아래 "2026-08-19 갱신" 참고)

### 배경

Decision 019는 "기업 DB(약 100개)를 Salesforce에서 어떤 Object 형태로 관리할지는
확정하지 않는다(TBD)"로 열어뒀다 — Lead Status=Candidate로 표현하는 방식과, 별도
외부 데이터 소스로 유지하는 방식 둘 다 가능성으로 남겨둔 상태였다. 이후 팀이 Excel
Object/Field Design(`🦙 CloudAlpacas - 메타데이터 기록 [B2B 확장]`)을 실제로 작업하는
과정에서, 기업 DB 행이 Account/Lead 같은 실제 Salesforce Object와 같은 표에 섞여
있어 Object처럼 오해될 수 있다는 문제가 발견됐다. 이를 계기로 이 TBD를 명확히
닫기로 했다.

**2026-08-19 갱신 배경**: 위 결정 직후, "데이터 확보 방식(DART API 연동 vs CSV
업로드)"을 대등한 두 선택지처럼 TBD로 남겨둔 표현이 여러 문서에 퍼졌다. 이는
"CSV가 기업 DB의 저장소"라는 오해나 "100개를 어디서 가져오는지 여전히 미정"이라는
인상을 줄 위험이 있었다. 이를 명확히 하기 위해 같은 Decision 안에서 Primary
Data Source를 확정한다.

### 결정

1. **기업 DB(약 100개)는 Salesforce Object가 아니다.** Lead Status=Candidate로
   표현하는 방식은 채택하지 않는다 — Agentforce Matching의 **External Input /
   Data Source**로만 취급하며, 100개 전체를 Salesforce에 저장하지 않는다.
2. **Primary Data Source는 DART Open API로 확정한다.** CSV를 기업 DB의 기본
   저장/확보 방식으로 삼지 않는다 — CSV는 필요할 때만 쓰는 **개발/테스트용 대체
   입력(Optional)**일 뿐이며, 현재 아키텍처의 확정 사항이 아니다.
3. **Agentforce Matching의 출력을 "Top 10 Recommendation"이라는 별도 개념으로
   명시한다.** 이 역시 Salesforce Object가 아니며, **반드시 DB에 저장해야 하는
   레코드로 정의하지 않는다** — 아직 Lead가 아니다.
4. **전체 흐름을 다음과 같이 확정한다**:
   > DART Open API → 약 100개 기업 데이터 조회 → Agentforce Matching(Fan 360
   > 데이터와 결합) → Top 10 Recommendation → **담당자가 기업을 선택** →
   > (선택된 기업만) Standard Lead 생성 → Account/Contact → Opportunity →
   > Sponsorship Product/Quote → Pipeline/Revenue
5. **100개 기업 전체를 Lead 100개로 생성하지 않는다.** Top 10 중에서도 담당자가
   실제 영업 대상으로 **선택한** 기업만 Lead가 된다 — Decision 018-A(Lead
   흡수)·019(Fan Fit≠Lead Score)를 그대로 따른다.
6. **새 Custom Object/Field는 만들지 않는다** — `Company Candidate Pool`,
   `Partner_Candidate__c` 등은 이번에도 채택하지 않는다(Decision 018-A와 동일 원칙).
7. **DART Open API의 실제 Salesforce/Agentforce 연동 기술 방식(커넥터, Apex
   콜아웃, External Object 등)은 이번 Decision에서 구현 결정하지 않는다** —
   "Primary Data Source가 DART Open API"라는 방향만 확정하며, 실제 연동 아키텍처는
   별도 구현 TBD로 남긴다.

### 이 Decision이 바꾸지 않는 것

- Decision 017(Agentforce = Phase 2 AI Matching 예외), 018의 A~K 기술 선택,
  019의 Business Story 방향·Fan Fit≠Lead Score 구분·d'Alba 대표 시나리오·Fan
  5,000명 목표 — 전부 그대로 유지한다. 이번 Decision은 019가 TBD로 남겨둔
  "기업 DB의 Object 형태"와 "데이터 출처"를 닫는다.

### 이유

Excel Object/Field Design에서 기업 DB가 Object 목록과 같은 표에 섞여 있으면,
구현 단계에서 실수로 100개 기업을 Custom Object나 Lead 100개로 만들 위험이 있다.
"기업 DB는 Object가 아니다"를 명시적으로 확정해두면 이 위험을 문서 차원에서
차단할 수 있다. 또한 "DART API vs CSV"를 대등한 선택지로 남겨두면 실제 구현
시 CSV를 기본값으로 오해할 위험이 있어, Primary Data Source를 DART Open API로
못박아 이 위험도 함께 차단한다 — 다만 "어떻게 연동할지"(기술 구현)는 Business
방향 결정과는 다른 문제이므로 별도 TBD로 분리한다.

### 영향

- `00_STORY.md §8.3`, `01_PROJECT.md §2.7`, `03_SYSTEM.md §7 B`, `04_DEMO.md
  §12`, `02_TEAM_GUIDE.md §13`, `docs/members/03_HYEJUNE.md`가 이 Decision을
  근거로 갱신됐다.
- Excel Object/Field Design(`🦙 CloudAlpacas - 메타데이터 기록 [B2B 확장]`)의
  `02_HYEJUN`, `00_OBJECT_MAP` 탭에 이미 이 구조(External Input → Agentforce →
  Top 10 Recommendation → Lead)가 반영되어 있다 — Excel은 사라가 직접 관리한다.
  Excel의 "DART API / 기업 CSV" 표기를 "DART Open API(Primary)"로 갱신할지는
  사라가 판단한다(Excel은 이 세션에서 더 이상 수정하지 않는다).

### TBD (아직 확정하지 않은 것)

- DART Open API의 실제 Salesforce/Agentforce 연동 기술 방식(커넥터, Apex 콜아웃,
  External Object 등) — Business 방향(Primary=DART)만 확정, 구현은 미정
- CSV를 개발/테스트용으로 실제 사용할지 여부와 형식(필요할 때만 검토)
