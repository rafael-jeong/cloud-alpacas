# ☁️ Cloud Alpacas

## 1. 우리가 누구고, 무엇을 만드는가

우리 팀 이름은 **Cellsforce**입니다.

우리는 **한화 이글스를 모델링한 가상의 구단 'Cloud Alpacas'**의 **Fan Relationship Management(FRM) Team**이 되어 Salesforce Customer 360을 설계합니다. 즉, 한화 이글스는 우리가 참고한 실제 모델(reference)이고, 우리가 실제로 만들고 다루는 대상은 가상의 구단 **Cloud Alpacas**입니다.

이번 프로젝트는 Salesforce 기능을 공부하는 프로젝트가 아닙니다. 실제 기업 프로젝트처럼 **Cloud Alpacas의 팬 데이터를 하나로 연결하고**, 팬을 이해하며, 적절한 시점에 가장 적합한 경험을 제공할 수 있는 **Customer 360 플랫폼**을 만드는 것이 목표입니다.

우리는 티켓 예매 시스템이나 쇼핑몰을 만드는 것이 아니라, **팬을 이해하고 성장시키는 Salesforce Customer 360**을 설계합니다.

8/14 Phase 1 Demo에서는 Cloud Alpacas의 FRM Manager인 **김매니저**가 Salesforce를 사용하여 신규 팬 **이루키**를 충성 팬으로 성장시키는 과정을 보여주었습니다. 현재는 이 Fan 360 데이터를 기반으로 **MVP 고도화**와 **B2B Collaboration/Sponsorship Expansion**을 함께 진행하는 **Phase 2** 단계입니다.

---

## 2. 프로젝트 목표

한화 이글스를 모델링한 Cloud Alpacas를 하나의 B2C 스포츠 기업으로 바라보고, Salesforce Customer 360을 기반으로 다음까지 실제 프로젝트처럼 수행합니다.

- Business 분석
- Customer Journey 설계
- Domain Modeling
- Data Modeling
- Salesforce Org 설계
- Demo Story
- Dummy Data

우리의 Business Goal은 다음과 같습니다.

> **신규 팬을 이해하고, 적절한 시점에 개인화된 액션을 통해 충성 팬으로 성장시키고, 장기적으로 Fan Lifetime Value를 높인다.**

모든 설계와 구현은 이 목표를 달성하기 위한 수단입니다.

이 Business Goal은 **Phase 1(B2C Fan 360 MVP, ~2026-08-14 완료)**의 목표였습니다.

현재 프로젝트는 **Phase 2(MVP 고도화 + B2B Collaboration/Sponsorship Expansion)**로 넘어와, 이 Fan 360 데이터를 구단의 제휴·스폰서 영업 의사결정에 활용하는 방향으로도 확장하고 있습니다. Phase 2의 세부 Business Goal과 Pain Point는 이후 `00_STORY.md`에서 별도로 정의합니다.

---

## 3. 프로젝트 철학 (Business First)

우리는 Salesforce 기능부터 생각하지 않습니다. 항상 아래 순서를 지킵니다.

**Business → Problem → Persona → Story → Domain → Workflow → Salesforce → Demo**

Salesforce는 문제를 해결하기 위한 도구입니다. Object를 먼저 만들거나 Flow부터 구현하지 않습니다.

항상 **"왜 이것이 필요한가?"**를 먼저 설명하고, 그다음 **"Salesforce에서는 어떻게 구현하는가?"**를 설명합니다.

---

## 4. 프로젝트 세계관 (Cloud Alpacas)

**Cloud Alpacas**는 한화 이글스를 모델링한 가상의 프로야구 구단이고, **Cellsforce**는 그 구단의 **Fan Relationship Management(FRM) Team**이 되어 이 프로젝트를 수행합니다.

FRM Team의 역할은 팬 데이터를 분석하는 것이 목적이 아니라, 팬을 이해하고, 팬의 현재 상태를 파악하며, 가장 적절한 Next Best Action을 실행하여 팬이 Cloud Alpacas와 더 오래 함께하도록 돕는 것입니다.

Cloud Alpacas의 이야기는 팬과 구단 운영에서 시작해, 이후 팬 데이터를 활용한 제휴·스폰서십 영역으로 확장됩니다.

### B2C Story

FRM Team의 역할은 팬 데이터를 분석하는 것 자체가 목적이 아니라, 팬을 이해하고, 팬의 현재 상태를 파악하며, 가장 적절한 Next Best Action을 실행하여 팬이 Cloud Alpacas와 더 오래 함께하도록 돕는 것입니다.

- **김매니저** : 팬 데이터를 관리하고 팬을 이해하며 Next Best Action을 실행하는 Cloud Alpacas의 FRM Manager. Salesforce Customer 360을 사용하는 사용자(User)
- **이루키** : SNS를 통해 처음 Cloud Alpacas를 알게 된 신규 팬(Customer)

Customer 360은 이루키의 행동을 하나의 화면에서 연결하여 보여주고, 김매니저는 그 정보를 바탕으로 적절한 Action을 실행합니다.

### B2B Expansion Story

팬은 늘고 있지만 구단 재정 운영상 적자인 상황에서, Cloud Alpacas는 팬 데이터를 활용해 새로운 스폰서/제휴사를 발굴하고 영업 기회로 연결해야 합니다.

- **이 매니저** : Cloud Alpacas의 스폰서 및 제휴 담당자
  - 팬이 증가하고 있지만 구단 재정 운영상 적자 상황에서 새로운 스폰서/제휴사를 발굴해야 함
  - 어떤 기업이 Cloud Alpacas의 팬층과 잘 맞는지 판단하기 어려움
  - 팬 데이터를 활용해 잠재 제휴사/스폰서사를 발굴하고 영업 기회로 연결하고 싶음
  - 단기 Collaboration을 통해 성과를 검증하고 장기적인 Partnership/Sponsorship으로 발전시키고 싶음

이 Story의 상세 여정과 시나리오는 이후 `00_STORY.md`에서 별도로 정의합니다.

---

## 5. 프로젝트 진행 단계 (Phase 1 완료 → Phase 2 진행 중)

Cloud Alpacas 프로젝트는 아래와 같이 단계적으로 진행합니다. Phase 1/Phase 2의 시간 구분(~8/14, 8/15~)은 `02_TEAM_GUIDE.md`에서 정의한 것과 동일합니다.

### Phase 1 — B2C Fan 360 MVP (완료, ~2026-08-14)

- B2C Fan 360 MVP 개발 및 8/14 Demo 완료
- 이루키 / 김매니저를 중심으로 한 B2C Fan 360 Story
- Salesforce Customer 360
- 이루키의 Fan Journey
- Fan 360 Dashboard
- Fan Profile
- Fan Timeline
- Fan Segmentation
- Recommendation (Next Best Action)
- Salesforce Flow
- Slack Notification
- Demo용 Fan App (Ticket / Admission / Goods / Membership 등 이벤트 생성)

Phase 1에서 **Fan App은 주인공이 아닙니다.** Fan App은 티켓 구매, 체크인, 굿즈 구매 등의 이벤트를 생성하여 Salesforce에 데이터를 전달하는 **Demo용 채널**입니다.

Phase 1의 핵심은 **Salesforce Customer 360**이며, 8/14 Demo 역시 Customer 360을 중심으로 진행했습니다.

### Phase 2 — MVP 고도화 + B2B Expansion (진행 중, 2026-08-15 ~)

Phase 2는 **B2B Sponsorship Sales만을 의미하지 않습니다.** 아래 두 방향을 함께 포함합니다.

**1. MVP 고도화**

Phase 1 B2C Fan 360 MVP의 안정화, 세부 기능 보완, 필요한 UX/데이터/자동화 개선을 계속합니다. 구체적인 개발 프로세스(브랜치 전략 등)는 `02_TEAM_GUIDE.md`를 따릅니다.

**2. B2B Sponsorship Sales Expansion**

Phase 1에서 구축한 Fan 360 데이터를 기반으로 광고주·스폰서 영업(Sales Pipeline) 영역으로 확장합니다. Cloud Alpacas는 팬이 증가하고 있지만 구단 재정 운영상 적자 상황이라, 팬덤의 광고 가치를 근거로 새로운 스폰서·광고주를 발굴하고 실제 계약(Revenue)으로 연결해야 합니다. 기존 Fan 360을 버리는 것이 아니라, 그 위에 새로운 흐름을 더하는 것입니다.

핵심 흐름(2026-08-18 멘토링 반영, `05_DECISIONS.md` Decision 019):

> Fan 360 Data → Fan Insight(팬덤 광고 가치 발견) → 기업 DB(약 100개) → Agentforce Matching/Top 10 추천 → Outbound Lead → Lead Qualification/Lead Score → Account/Contact → Opportunity → Sponsorship Package/Quote → Negotiation → Closed Won → Contract/Sponsorship Revenue → Pipeline/Revenue Dashboard

> 핵심은 "Collaboration을 잘할 기업을 찾는 것"이 아니라 **"Cloud Alpacas에 광고비/스폰서십 비용을 지불할 가능성이 높은 기업을 발굴해 실제 Sales Pipeline으로 연결하는 것"**입니다. Collaboration(단기 협업)은 이 흐름에서 여전히 유효한 개념이지만(Campaign Record Type으로 구현, Decision 018-D), Phase 2 전체를 대표하는 중심 개념은 아닙니다.

B2B 영역의 상세 Story, Persona, Object, Field, 역할 분담은 확정되는 대로 `00_STORY.md`, `01_PROJECT.md`, `03_SYSTEM.md`, `02_TEAM_GUIDE.md`에 각각 반영합니다.

### Future Scope (Phase 2에서도 아직 하지 않는 것)

Marketing Cloud, Data Cloud, 실제 결제 및 외부 API/AWS 기반 실시간 데이터 연동 등은 Phase 2 범위에도 포함하지 않으며 Future Scope로 관리합니다.

Agentforce는 원칙적으로 Future Scope입니다. 단, 아래 두 가지 예외가 승인되었습니다.

1. 2026-08-18 Phase 2 Technical Decision 회의에서 **B2B AI Matching(Segment Match·Recommendation Reason 자동 생성 포함)**을 예외적으로 Phase 2 범위에 포함하기로 결정했습니다(`05_DECISIONS.md` Decision 017).
2. 2026-08-27 팀 전체 승인으로 **Opportunity 영역의 Agentforce Agent 구조(메인 Opportunity Agent + Subagent 5개 — Activity Management/Deal Intelligence/Discovery Management/Proposal·Quote/Negotiation)**를 두 번째 예외로 Phase 2 범위에 포함하기로 결정했습니다(`05_DECISIONS.md` Decision 022).

이 두 예외는 각각 명시된 범위(AI Matching, Opportunity 영역 5개 Subagent)에만 적용되며, 그 외 Agentforce 활용(예: Fan Summary, Next Best Action 설명 등)은 여전히 Future Scope입니다.

새로운 아이디어가 나오더라도 현재 Phase(1 또는 2) 범위를 벗어나면 바로 구현하지 않고 Future Scope로 기록합니다.

---

## 6. Claude 사용 원칙 ⭐⭐⭐⭐⭐

우리 팀은 모두 Salesforce 프로젝트가 처음인 **Baby Team**입니다. Claude는 항상 아래 원칙을 지킵니다.

**설명 방식**
- 어려운 용어를 먼저 사용하지 않습니다.
- Salesforce 기능보다 Business를 먼저 설명합니다.
- 새로운 개념은 반드시 예시와 비유를 함께 설명합니다.
- 하나의 개념만 설명하고 다음 단계로 넘어갑니다.
- 항상 "왜 이것을 하는가?"부터 설명합니다.
- 모르는 것을 부끄럽게 만들지 않습니다. 애매한 내용은 추측하지 말고 질문합니다.

**답변 관점**
Claude는 단순히 답을 알려주는 AI가 아니라, 항상 아래 네 가지 관점에서 함께 고민합니다.

- Salesforce Enterprise Architect
- Business Analyst
- CRM Consultant
- Product Manager

답을 바로 제시하기보다, 왜 그렇게 설계하는지 → 다른 선택지는 무엇인지 → 이번 프로젝트에서는 어떤 선택이 가장 적절한지 순서로 설명하고 추천합니다. 모든 설명은 친절하고 다정하게 합니다.

---

## 7. 문서와 프로젝트 관리 원칙 (Source of Truth)

Cloud Alpacas 프로젝트는 문서를 최소화하되, **각 문서의 역할은 명확하게 분리**합니다. 같은 내용을 여러 문서에 중복 작성하지 않습니다. 문서 간 내용이 충돌할 경우 아래 문서를 기준으로 판단합니다.

| 문서 | 역할 |
|------|------|
| `00_STORY.md` | 프로젝트가 왜 존재하는지, Business Goal, Pain Point, Persona, Story |
| `01_PROJECT.md` | Domain Model, Workflow, Backlog, 프로젝트의 전체 설계 |
| `02_TEAM_GUIDE.md` | 팀 운영 방식, GitHub Projects, Git/Slack Convention, 역할 정의 |
| `03_SYSTEM.md` | Salesforce Object, Data Model, Architecture, ERD, Flow |
| `04_DEMO.md` | Demo Story, Sample Data, Screen, 발표 시나리오 |
| `05_DECISIONS.md` | 프로젝트 전체에 영향을 주는 의사결정(ADR) 기록 |

예를 들어 Business 변경은 `00_STORY.md`, Workflow 변경은 `01_PROJECT.md`, Object 변경은 `03_SYSTEM.md`, 프로젝트 정책 변경은 `05_DECISIONS.md`를 수정합니다.

**지켜야 할 원칙**

- 프로젝트 전체에 영향을 주는 변경(Object 구조, Workflow, Persona, MVP 범위 등)은 반드시 `05_DECISIONS.md`에 Decision으로 기록합니다.
- 문서는 "왜 만드는가"를 설명하고, GitHub Projects는 "오늘 무엇을 하는가"를 관리합니다. Task, Sprint, Bug, Progress는 문서가 아니라 GitHub Projects에서 관리합니다.
- 기존 문서를 함부로 수정하지 않습니다. 크게 변경해야 하는 경우 먼저 관련 문서와 충돌 여부를 확인하고, 애매한 경우 추측하지 말고 질문합니다.
- AI가 다른 제안을 하더라도 공식 문서(Source of Truth)가 우선입니다.

---

## 8. 프로젝트 구조

```text
CloudAlpacas/

├── CLAUDE.md
│
├── docs/
│   ├── 00_STORY.md
│   ├── 01_PROJECT.md
│   ├── 02_TEAM_GUIDE.md
│   ├── 03_SYSTEM.md
│   ├── 04_DEMO.md
│   ├── 05_DECISIONS.md
│   │
│   ├── members/
│   │   ├── README.md
│   │   ├── 00_SARA.md
│   │   ├── 01_SEUNGWOO.md
│   │   ├── 02_EUNYEONG.md
│   │   ├── 03_HYEJUNE.md
│   │   └── 04_AARON.md
│   │
│   └── data/
│       ├── SAMPLE_DATA.md
│       └── DEMO_DATASETS.md
│
├── force-app/
│
└── README.md
```

**폴더 역할**

- **docs/** : 프로젝트의 설계 문서(Source of Truth)
- **docs/members/** : 팀원 개인 온보딩 문서
- **docs/data/** : Demo 및 Dummy Data
- **force-app/** : Salesforce Org Metadata
- **README.md** : 프로젝트 소개