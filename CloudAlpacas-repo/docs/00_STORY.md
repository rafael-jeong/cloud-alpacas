# 00_STORY.md — Cloud Alpacas Customer 360 Story

> 이 문서는 "왜 이 프로젝트가 존재하는가"를 설명한다.
> Business Goal, Pain Point, Persona, Story(Customer Journey)까지만 다루며,
> Domain/Entity/Salesforce Object 설계는 다루지 않는다(→ `01_PROJECT.md`, `03_SYSTEM.md`).

---

## 1. Business Goal

> **신규 팬을 이해하고, 적절한 시점에 개인화된 액션을 통해 충성 팬으로 성장시키고,
> 장기적으로 시즌권 구매까지 이어지는 Fan Lifetime Value를 높인다.**

모든 설계와 구현은 이 목표를 달성하기 위한 수단이다.

이 목표는 **Phase 1(B2C Fan 360 MVP)**의 목표다. Phase 1이 끝났다고 사라지는 것이 아니라 Phase 2에서도 계속 유지된다 — Phase 2는 이 목표를 대체하지 않고, 그 위에 새로운 목표를 더한다(CLAUDE.md §5).

### [P2] Phase 2 Business Goal

> **Phase 1에서 쌓은 Fan 360 데이터를 활용해 팬덤의 광고 가치를 발견하고, Cloud Alpacas에 광고비/스폰서십 비용을 지불할 가능성이 높은 기업을 발굴해, 이를 실제 Sales Pipeline(Lead → Opportunity → Contract)으로 연결함으로써 구단의 Sponsorship Revenue를 늘린다.**
>
> (2026-08-18 멘토링으로 갱신 — `05_DECISIONS.md` Decision 019. 기존에는 "궁합이 좋은 기업과 단기 Collaboration으로 검증한 뒤 장기 Partnership으로 발전"이 목표였다면, 이제는 "광고 가치가 있는 기업을 발굴해 Sales Pipeline/Revenue로 직접 연결"하는 것이 핵심이다. Collaboration이라는 개념 자체가 사라지는 것은 아니지만 — 여전히 Campaign Record Type으로 구현되는 단기 실행 수단이다(Decision 018-D) — Phase 2를 대표하는 중심 개념은 아니다.)

Cloud Alpacas는 팬이 늘고 있지만 구단 재정 운영상 적자 상황이다 — 팬을 키우는 것만으로는 구단의 지속 가능성 문제가 풀리지 않는다. Phase 2는 Phase 1이 만든 Fan 360 데이터를 "팬을 더 이해하는 데"뿐 아니라 "구단의 Sponsorship 영업 Pipeline과 매출을 넓히는 데"에도 쓰기 시작하는 단계다.

---

## 2. Pain Point — Salesforce 도입 전 Cloud Alpacas의 문제

**1. 팬 정보를 한눈에 볼 수 없다.**
티켓, 굿즈, 멤버십, 앱, 문의 데이터가 모두 다른 시스템에 흩어져 있다.
→ 팬은 보이지 않고 데이터만 보인다.

**2. 팬을 이해하지 못한다.**
이루키가 '문선수'를 좋아하는지, 직관을 자주 오는지, 굿즈를 샀는지 연결해서 볼 수 없다.
→ 360° Fan View가 없다.

**3. 팬을 세분화하지 못한다.**
누가 Ticket Only Fan인지, Membership Candidate인지, VIP 후보인지 자동으로 알 수 없다.
결국 모든 팬에게 같은 이벤트, 같은 쿠폰, 같은 메시지를 보낸다.

**4. 적절한 타이밍을 놓친다.**
VIP가 될 가능성이 높은 팬도 엑셀을 정리한 후에야 발견한다.
→ "한 달 전에 알았으면 멤버십을 가입했을 텐데…"

**5. 무엇을 해야 할지 우선순위를 알 수 없다.**
신규 팬이 1,000명 생겨도 누구에게 굿즈를 추천해야 하는지, 멤버십을 제안해야 하는지,
시즌권을 권해야 하는지 판단할 수 없다.
→ 데이터는 많지만 Action이 없다.

### [P2] Phase 2 Pain Point — 이 매니저가 겪는 문제

**1. 팬은 늘고 있는데 왜 적자인가?**
티켓·멤버십·굿즈 매출만으로는 구단 재정 적자를 해결하지 못한다. 팬 성장과 구단 재정 사이의 간극을 메울 새로운 수익원이 필요하다.

**2. 어떤 기업이 우리 팬덤에 광고비를 지불할 가능성이 높은지 알 수 없다.**
"유명한 회사"에 무작정 제안서를 보내는 것과, 실제로 우리 팬덤에게 광고 가치가 있는 기업을 찾는 것은 다르다. 지금은 이 판단 근거가 없다.

**3. 우리 팬이 실제로 무엇에 관심 있는지 모른 채 영업하게 된다.**
팬이 어떤 상품·브랜드·선수·콘텐츠(예: 뷰티, 라이프스타일, F&B 등)에 반응하는지 정리된 데이터 없이, 감이나 인맥에 의존해 광고주에게 제안하게 된다.

**4. 후보 기업과 팬층의 광고 Fit을 검증할 방법이 없다.**
"이 브랜드의 타겟 고객층이 우리 팬덤과 정말 겹치는가?"를 확인할 근거 없이 제안이 오가면, 계약이 성사돼도 실제 광고 효과가 기대에 못 미칠 위험이 크다.

**5. 추천된 기업 중 실제로 영업(Outbound)을 시작할 가치가 있는 곳을 가려낼 방법이 없다.**
Fit이 높다고 해서 곧바로 계약 가능성이 높은 것은 아니다 — 담당자의 의사결정 권한, 접촉 이력, 예산 등 실제 영업/계약 가능성은 별도로 판단해야 하는데, 지금은 이 둘을 구분할 방법이 없다.

**6. Pipeline과 실제 계약(Revenue)으로 이어지는 흐름을 관리할 방법이 없다.**
후보 발굴부터 계약까지 각 단계(Lead → Opportunity → Contract)가 어디서 막히는지, 목표 매출 대비 얼마나 부족한지 한눈에 볼 수 없다.

**7. 과거 장기 스폰서 캠페인이 잘못된 타깃 가정으로 진행되어 기대만큼 성과를 내지 못한 경험이 있다.**
Cloud Alpacas는 이전에 "야구 팬은 40~50대 남성"이라는 가정에 따라 해당 타깃에 맞춘 스폰서·장기 캠페인을 진행한 적이 있지만, 실제 팬 데이터를 근거로 검증하지 않은 가정이었기에 기대만큼의 화제성과 성과로 이어지지 못했다. 이 경험이 이번에 Fan 360 데이터를 근거로 광고 가치가 높은 기업을 찾고, 실제 Sales Pipeline으로 검증하는 방식을 택하게 된 배경이다.

---

## 3. FRM Team

> "우리는 고객이 아니라 팬을 관리한다."

Cellsforce는 Cloud Alpacas의 **Fan Relationship Management(FRM) Team**이 되어 이 문제를 해결한다.

**Mission**
팬 데이터를 기반으로 팬의 현재 상태를 이해하고, 가장 적절한 다음 행동(Next Best Action)을
실행하여 Fan Lifetime Value를 높인다.

**KPI**
- 신규 팬 활성화율
- 첫 경기 관람 전환율
- 재방문율
- 첫 굿즈 구매율
- 멤버십 가입률
- 시즌권 구매 전환율
- Fan Lifetime Value

> **[P2] Phase 2에서는 이 Mission이 확장된다.** Cellsforce는 팬을 이해하는 것에서 나아가, 그 이해를 구단의 B2B Sponsorship Sales(광고주/스폰서 발굴 → Pipeline → Contract) 의사결정에도 활용한다 — 담당 Persona는 §4의 **이 매니저**를 참고한다.

---

## 4. Persona

### 김매니저 — Cloud Alpacas FRM Manager
Salesforce Customer 360을 사용하는 사용자(User).
**Mission**: 팬 데이터를 분석하여 팬을 이해하고, 가장 적절한 Next Best Action을 실행하여
신규 팬을 충성 팬으로 성장시킨다.

### 이루키 — 27세, 직장인 (신규 팬)
- 야구를 거의 본 적이 없다.
- SNS에서 우연히 문선수의 영상을 보고 처음 Cloud Alpacas에 관심을 갖게 된다.
- 친구와 함께 첫 직관을 경험한다.
- 응원 문화와 경기장의 분위기에 빠져 점점 클라우드 팬이 되어간다.

### [P2] 이 매니저(가칭) — Cloud Alpacas Sponsorship Sales Manager

Cloud Alpacas의 스폰서 및 광고 영업 담당자. 팬은 늘고 있지만 구단 재정 운영상 적자인 상황에서, 팬덤의 광고 가치를 근거로 새로운 광고주·스폰서를 발굴하고 실제 계약(Revenue)으로 연결하는 책임을 맡고 있다.

**Mission**: Fan 360 데이터를 근거로 Cloud Alpacas 팬덤에 광고/스폰서십 가치가 높은 기업을 발굴하고, 이를 실제 Sales Pipeline(Lead → Opportunity → Contract)으로 연결해 Sponsorship Revenue를 만든다.

**주요 고민**
- 팬은 늘고 있는데 왜 구단은 여전히 적자인가?
- "유명한 회사"가 아니라, 우리 팬덤에 실제로 광고 가치가 높은 기업을 어떻게 찾는가?
- 우리 팬이 실제로 어떤 상품·브랜드·콘텐츠(뷰티, 라이프스타일, F&B 등)에 반응하는지 어떻게 알 수 있는가?
- Agentforce가 추천한 기업(Fit 높은 후보) 중 실제로 Outbound 영업을 시작할 가치가 있는 곳을 어떻게 가려내는가? — **Fit이 높다고 곧바로 계약 가능성이 높은 것은 아니다.**
- Pipeline이 목표 매출 대비 얼마나 부족한지, 몇 개의 신규 스폰서가 더 필요한지 어떻게 파악하는가?

> 이 매니저의 여정은 이루키 같은 Phase 1 팬의 데이터와 이어져 있다 — 이루키 같은 팬들의 데이터가 쌓일수록, 이 매니저가 활용할 수 있는 근거도 함께 쌓인다. (이름은 아직 가칭이며, 세부 프로필은 이후 확정한다 — TBD)

---

## 5. Phase 1 Story — 이루키의 Customer Journey

```
SNS → 회원가입 → 첫 티켓 구매 → 첫 직관 → 첫 굿즈 구매 → 재방문 → 멤버십 가입 → 충성팬
```

김매니저는 Customer 360을 통해 이루키가 이 여정의 어디쯤 있는지 확인하고,
가장 적절한 시점에 개인화된 Action을 실행한다.

---

## 6. Current Segment (Life Cycle) — 팬의 현재 상태 정의

> Fan을 분류하는 축은 3개다 — **Current Segment(Life Cycle)**, **Engagement Level**,
> **Fan Value**(05_DECISIONS.md Decision 009). 이 표는 그중 **Current Segment(Life
> Cycle)** — "지금 이 팬이 활동 주기의 어디에 있는가" — 만 다룬다. "Segment"라는 단어를
> Engagement Level이나 Fan Value(VIP 포함)와 혼용하지 않는다. 나머지 두 축의 필드
> 정의는 `03_SYSTEM.md` §2.1에서 다룬다.

| Segment(Life Cycle) | 정의 | 주요 Action |
|---|---|---|
| New Fan (미활성) | 가입만 하고 아직 행동 없음 | 첫 티켓 구매 유도 |
| Active Fan | 최근 90일 활동 | 개인화 추천 |
| At-Risk Fan | 활동 감소 | 이탈 방지 |
| Dormant Fan | 181~365일 활동 없음 | 복귀 캠페인 |
| Churned Fan | 365일 이상 활동 없음 | 저빈도 재활성화 |
| Unreachable Fan | 수신 불가 | 동의/연락처 관리 |

---

## 7. FRM Team의 Next Best Action (Phase 1)

| 이루키의 상태 | FRM Team Action |
|---|---|
| 회원가입만 함 | Welcome Campaign |
| 티켓 구매 안 함 | First Ticket Campaign |
| 첫 직관 완료 | First Visit Guide |
| Ticket Only Fan | First Merchandise Campaign |
| 굿즈 구매 완료 | Favorite Player Campaign |
| 재방문 시작 | Membership Campaign |
| 충성 팬 | Season Ticket Recommendation *(향후)* |
| At-Risk Fan | Win-back Campaign *(향후)* |

---

## 8. [P2] Phase 2 Story — B2B Sponsorship Sales Journey

> **2026-08-18 멘토링으로 이 섹션 전체가 갱신됐다**(`05_DECISIONS.md` Decision 019).
> 기존에는 산리오(Sanrio) Collaboration을 대표 시나리오로 삼아 "궁합 좋은 기업 →
> 단기 Collaboration → 장기 Partnership"의 흐름을 다뤘다. 이제는 **"팬을 이해하고,
> 기업을 찾아, 계약으로 연결하다"**를 핵심 메시지로, d'Alba(달바)를 대표 시나리오로
> 삼아 Sales Pipeline/Revenue 중심으로 다시 쓴다. 핵심은 "Collaboration을 잘할
> 기업을 찾는 것"이 아니라 **"Cloud Alpacas에 광고비/스폰서십 비용을 지불할
> 가능성이 높은 기업을 발굴하는 것"**이다.

### 8.1 왜 구단이 B2B Sponsorship Sales로 확장해야 하는가

Phase 1은 이루키 같은 신규 팬을 충성 팬으로 성장시키는 데 집중했다. 하지만 팬이 늘어난다고 구단의 재정 문제가 저절로 풀리지는 않는다 — Cloud Alpacas는 팬이 증가하는 중에도 구단 재정 운영상 적자 상태다. 티켓·멤버십·굿즈 매출만으로 감당하기 어려운 이 간극을, 새로운 광고주·스폰서 확보라는 수익원으로 메워야 한다.

과거에는 "야구 팬은 40~50대 남성"이라는 가정에 따라 해당 타깃에 맞춘 스폰서·장기 캠페인을 진행했지만, 실제 팬 데이터로 검증하지 않은 가정이었기에 기대만큼의 화제성과 성과로 이어지지 못했다(§2 Pain Point 7). 이 경험이 이번에는 Fan 360 데이터를 근거로 광고 가치가 높은 기업을 찾고, 이를 실제 Sales Pipeline으로 검증하는 방식을 택하게 된 배경이다.

### 8.2 왜 Fan 360 데이터가 필요한가

기존 방식이라면 스폰서 영업은 "유명한 회사에 제안서를 보내는" 방식에 가깝다 — 실제로 그 기업의 타겟 고객층이 Cloud Alpacas 팬덤과 맞는지, 광고 가치가 있는지 확인할 근거가 없다. Phase 1에서 쌓은 Fan 360 데이터(관심사, 구매 이력, 관람 패턴, Engagement 수준 등)는 이 "광고 가치가 있는지"를 판단할 수 있는 근거다. B2B 영업이 감이 아니라 데이터에서 출발해야 하는 이유가 여기에 있다.

### 8.3 이 매니저의 여정 — Fan Insight에서 Sponsorship Revenue까지

```
Fan 360 Data 분석 → 팬덤의 광고 가치 발견 → 기업 DB(약 100개) → Agentforce Matching/Top 10 추천
→ Outbound Lead → Lead Qualification/Lead Score → Account/Contact → Opportunity
→ Sponsorship Package/Quote → Negotiation → Closed Won → Contract/Sponsorship Revenue
→ Pipeline/Revenue Dashboard
```

**1. Fan 360 Data 분석 → 팬덤의 광고 가치 발견**

이 매니저는 Fan 360 데이터를 살펴보다가, 최근 여성 팬의 유입이 크게 늘었다는 것을 발견한다. 그런데 자세히 들여다보니 팬 수 증가와 달리 이 팬층의 구매력과 재방문율은 오히려 낮다 — 단순히 팬 수를 늘리는 것만으로는 구단의 가치가 커지지 않는다는 신호다. Fan 360을 다시 분석해보니, 이 팬층은 **뷰티(Beauty)·라이프스타일(Lifestyle)·F&B** 관련 콘텐츠에 유독 높은 관심을 보인다. 이 특성이 "우리 팬덤에게 어떤 산업의 기업이 광고 가치가 있을지"를 판단하는 근거가 된다.

> 정확한 증가율·구매력 격차 등 실제 수치는 `docs/data/P2_DUMMY_DATA_MASTER.md`에서 관리한다. "구단이 먼저 제안할 후보"가 감이 아니라 데이터 기반 가설이라는 점이 이 단계의 핵심이다.

**2. 기업 DB(약 100개) → Agentforce Matching → Top 10 추천**

이 매니저는 실제 기업 정보로 구성된 기업 DB(약 100개, 화장품/뷰티·F&B·자동차·핀테크·OTT 등 다양한 산업)를 확보한다. Agentforce가 Fan 360 Insight와 이 기업 DB를 매칭해 **Top 10 후보를 추천**하고, 각 추천에는 **Recommendation Reason**(왜 이 기업이 우리 팬덤과 맞는지)이 함께 제공된다. 이 매칭 결과가 바로 **Fan Fit/Recommendation Score**다 — 아직 영업 대상으로 확정된 것은 아니다.

> 대표 예시: **d'Alba(달바)** — 뷰티/스킨케어 브랜드로, Top 10 추천 중 Fan Fit이 높은 대표 사례로 쓰인다. 기업 데이터의 **Primary Data Source는 DART Open API**로 확정했다(`05_DECISIONS.md` Decision 020) — 100개 기업은 Salesforce에 저장하지 않으며, CSV는 필요할 때만 쓰는 개발/테스트용 대체 입력일 뿐이다. 실제 연동 기술 방식은 TBD.

**3. Top 추천 → Outbound Lead 등록**

Agentforce가 추천한 기업은 "추천 후보"일 뿐, 아직 Lead가 아니다. 이 매니저(또는 팀)가 **실제 Outbound 영업 대상으로 선정**한 기업만 Lead로 등록한다. Lead Status로 후보/접촉/검토/Qualified 등 영업 진행 단계를 표현한다(Decision 018-A — 별도 Object가 아니라 Lead로 흡수).

**4. Lead Qualification / Lead Score — Agentforce Score와는 다른 개념**

이 매니저는 Lead가 된 기업을 실제로 계약까지 끌고 갈 수 있는지 판단한다. **이 판단은 2단계 앞서 나온 Agentforce의 Fan Fit/Recommendation Score와는 완전히 다른 질문이다:**

| | Agentforce Fit/Recommendation Score | Lead Score |
|---|---|---|
| 질문 | 우리 팬덤과 이 기업이 잘 맞는가? | 이 Lead가 실제로 계약까지 이어질 가능성이 높은가? |
| 근거 | Fan 360 데이터, Target Segment, Segment Match | 담당자의 의사결정 권한, 직무/역할, 접촉 이력, 메시지·미팅 반응, 예산/구매 가능성 등 |
| 산출 주체 | Agentforce(2단계에서 자동 산출) | 이 매니저/영업 담당자의 실제 영업 활동 결과 |

Fit이 높다고 곧바로 계약 가능성이 높은 것은 아니다 — d'Alba처럼 Fan Fit이 높아도, 실제 담당자와 접촉하고 예산·의사결정권을 확인해야 진짜 Lead Score가 만들어진다.

**5. Account/Contact 전환 → Opportunity 생성**

Lead가 Qualified 단계를 지나면 Account/Contact로 전환되고, 실제 협상 단계인 Opportunity가 만들어진다(예: "d'Alba × Cloud Alpacas — Advertising Sponsorship").

**6. Sponsorship Package/Quote 제안 → Negotiation**

이 매니저는 구단이 판매할 수 있는 Sponsorship Package(구장 광고, 전광판/펜스 광고, 공식 SNS 노출, Brand Day, 프로모션, Collaboration Goods 등 — "무엇을 얼마에 파는가")를 Product/Quote로 제안하고 협상을 진행한다.

**7. Closed Won → Contract/Sponsorship Revenue → Pipeline/Revenue Dashboard**

협상이 성사되면 Closed Won으로 전환되고, 실제 계약(Sponsorship Revenue)으로 이어진다. 이 매니저는 이 흐름 전체를 Pipeline/Revenue Dashboard에서 확인한다 — 현재 Opportunity 수, Pipeline Amount, Stage별 분포, 목표 매출 대비 부족 금액 등(구체적인 지표/계산식은 `03_SYSTEM.md` §7에서 TBD로 관리한다).

> 이 흐름에서 반드시 필요한 것은 **"Fan 360 데이터 → 팬덤 광고 가치 → 기업 DB Matching"이라는 중간 단계**다. "팬 데이터가 있으니 광고주를 찾는다"가 아니라, "팬 데이터가 팬덤의 관심사(뷰티/라이프스타일/F&B 등)를 보여주고, 그 관심사가 기업 매칭의 근거로 이어진다"는 논리적 연결이 이 Story의 핵심이다. Collaboration(단기 협업 캠페인)은 이 흐름 안에서 필요하면 Opportunity 성사 이후 실행 수단으로 쓰일 수 있지만(Campaign Record Type, Decision 018-D), Story 전체를 대표하는 중심 개념은 더 이상 아니다.

### 8.4 [P2] 이 Story에서 아직 다루지 않는 것 (Future Scope)

- **계약 이후 성과 분석**: Sponsorship Revenue가 발생한 이후 실제 광고 효과·팬 반응을 분석하는 것은 Story 수준에서는 유효하지만, 이번 구현 범위에는 포함하지 않는다(`04_DEMO.md` §7 참고).
- **성과가 낮은 Sponsorship 재검토/관계 종료**: 판단 절차·기준 모두 TBD — Future Scope로 남긴다.
- **장기 재계약/Partnership 전환**: 첫 계약(Closed Won) 이후 장기 재계약으로 이어질지 판단하는 것은 Future Scope다.
- **Collaboration 성공 기준/KPI**: Collaboration을 실행 수단으로 쓸 경우의 성과 판단 기준은 확정하지 않았다(TBD).

---

## 9. [P2] Phase 2 — B2B Next Best Action / Decision Flow

§7이 "이루키(팬)의 상태 → FRM Team Action"을 정의했다면, 이 표는 "이 매니저가 발견한 신호 → 판단/Action"을 정의한다.

| 발견한 신호 | 이 매니저의 Action |
|---|---|
| 특정 팬층(관심사·구매·관람 패턴)이 뚜렷하게 드러남 | 팬덤의 광고 가치 가설 수립 |
| Agentforce가 기업 DB(약 100개)에서 Top 10 추천 | Recommendation Reason 확인, 실제 Outbound 대상 선정 |
| Outbound 대상으로 선정됨 | Lead 등록(Status: Candidate/후보) |
| 접촉·응답이 있음 | Lead Qualification 진행, Lead Score 평가(Agentforce Score와 별개) |
| Lead가 Qualified됨 | Account/Contact 전환, Opportunity 생성 |
| Opportunity 진행 중 | Sponsorship Package/Quote 제안, Negotiation |
| Negotiation 성사 | Closed Won → Contract/Sponsorship Revenue |
| Pipeline이 목표 매출 대비 부족함 | 추가 Outbound Lead 발굴 필요 판단 |
| 계약 이후 성과가 기대에 못 미침 | 재검토 또는 관계 종료 *(판단 기준 TBD, Future Scope, §8.4)* |

> 이 표의 각 단계를 Salesforce에서 어떤 Object/Field/Flow로 자동화할지는 이 문서(00_STORY.md)의 범위가 아니다 — `01_PROJECT.md`, `03_SYSTEM.md`, `05_DECISIONS.md`에서 다룬다.