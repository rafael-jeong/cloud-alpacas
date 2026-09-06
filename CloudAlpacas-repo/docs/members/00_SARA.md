# 사라

## [P2] Current Role

🦙 **Fan 360 고도화 + B2B 연결**. PM / Solution Architect / Product Designer
역할(`02_TEAM_GUIDE.md §1`)은 그대로 유지하되, Phase 2에서는 여기에 더해 **Fan
360 고도화와 B2C↔B2B 연결 지점(Fan Insight/Fan Grouping)을 직접 책임지는
Feature Owner**를 겸한다(`02_TEAM_GUIDE.md §11`). 동시에 Baby PM으로서 전체
Story·Scope·공용 Data 기준·Integration/QA 흐름을 연결한다(`02_TEAM_GUIDE.md §10`).

## [P2] Mission

Phase 1에서 쌓은 Fan 360 데이터가 Phase 2 B2B Sponsorship Sales 의사결정에 실제로
쓰일 수 있도록 Fan Insight/Fan Grouping을 설계하고, 그 결과가 다른 담당자의
Feature(특히 혜준의 기업 DB/Agentforce Matching)로 끊기지 않고 이어지게 만든다
(`00_STORY.md §8.2`, `01_PROJECT.md §2.7`).

> **✅ 2026-08-18 멘토링 갱신**(`05_DECISIONS.md` Decision 019): Fan Insight가
> 발견해야 하는 것이 "궁합 좋은 기업"에서 **"팬덤의 광고 가치"**(뷰티/라이프스타일
> 관심 등)로 구체화됐다 — 대표 시나리오는 d'Alba(달바). Fan Data 목표도 약
> 1,000명에서 **최소 5,000명**으로 상향됐고, Org에 5,024건 존재가 확인됐다
> (헤드카운트만 확인, Field/Distribution QA는 별도 — `data/DEMO_DATA_STANDARD.md §6.4`).

## [P2] Ownership

- **P1 Reuse**: Person Account(`Gender__c`/`Birthdate` 포함), `Current_Segment__c`/
  `Engagement_Level__c`/`Fan_Value_Tier__c` 3축, `Fan_Activity_Pattern__c`,
  `Engagement_Signal__c`(`03_SYSTEM.md §2.1`) — 이미 존재하는 Field를 Fan
  Insight 분석에 그대로 활용한다
- **Screen(확정)**: Fan Insight/Fan Grouping 화면 — **Standard Report + Report
  Type + Dashboard**로 확정(`03_SYSTEM.md §7 J`, `05_DECISIONS.md` Decision
  018-J). 별도 Custom Object/LWC 없음
- **B2B에 새로 연동되는 것**: Target Segment(Picklist, `§7 G`, 값 목록 TBD),
  Segment Match(Agentforce Matching, `§7 H`) — Fan Insight 결과가 혜준의 Lead
  Candidate 발굴로 이어지는 지점
- **B2C↔B2B 연결 지점**: Fan Insight 결과가 Collab360/Lead(Candidate 단계)
  발굴의 입력이 되는 지점 전체 — Partner Candidate는 별도 Object가 아니라
  Lead로 흡수됐다(Decision 018-A)

## [P2] End-to-End Responsibility

Requirement(`00_STORY.md §8` B2B가 Fan 360을 필요로 하는 이유) → Business/Domain
이해(`01_PROJECT.md §2.7`) → Salesforce Field(`Gender__c` 등, `03_SYSTEM.md §2.1`에
이미 반영) → Admin(Report/Report Type 설계) → Demo Data(`04_DEMO.md §10` Fan 분포
기준) → Flow/Automation(TBD) → Dev(LWC 필요 시, TBD) → 화면 → QA

## [P2] Shared Scenario

`SCN-B2B-001`의 **출발점(Fan Insight)**을 책임진다 — 이 결과가 혜준의 Partner
Candidate Discovery 입력이 된다(`02_TEAM_GUIDE.md §13`).

## [P2] Collaboration

- **혜준**: Fan Insight 결과를 Partner Candidate 후보 발굴에 넘긴다.
- **전체 팀**: Baby PM으로서 Integration/QA 흐름을 조율한다(`02_TEAM_GUIDE.md §15`).

## [P2] TBD / Decision Needed

2026-08-18 회의로 큰 방향은 모두 확정됐다(`05_DECISIONS.md` Decision 018).
남은 것은 세부 값뿐이다.

- Target Segment Picklist의 실제 값 목록(`§7 G`)
- Agentforce Segment Match의 상세 구성(`§7 H`, 혜준과 공동, Decision 017 TBD와 동일)

> 위 항목은 여전히 임의로 확정하지 않는다 — Fan Insight 화면 구현 방식(Report/
> Dashboard)과 Segment Match의 계산 주체(Agentforce)는 이미 확정됐으므로 더 이상
> 이 목록에 포함하지 않는다.

---

## [P1] Previous Role & Contribution

> Phase 1(B2C Fan 360 MVP)에서 사라가 실제로 수행한 역할과 기여를 보존한 History다.

# Mission

> **"이 프로젝트가 왜 존재하는지, 그리고 그 이유가 문서와 화면 설계에 끝까지 살아있게
> 만든다."**

Sara는 Cloud Alpacas 프로젝트의 PM / Solution Architect / Product Designer다. 팀
전체가 "왜 이것을 만드는가"에서 출발해 "그래서 Salesforce에서는 어떻게 만드는가"로
이어지도록(CLAUDE.md §3 Business First) 문서 구조와 Object 설계 방향, 화면 UX를
책임진다.

---

# Quick Start

처음 참여한다면 이 순서로 읽는다.

1. `CLAUDE.md` — 프로젝트 철학과 Baby Rule.
2. `00_STORY.md` — Business Goal, Persona, Customer Journey.
3. `01_PROJECT.md` — Domain Model, Entity, Salesforce Mapping 선택지.
4. `03_SYSTEM.md` — 확정된 Object/Field/ERD/Flow.
5. `05_DECISIONS.md` — 왜 그렇게 결정했는지(가장 중요 — Sara가 직접 이끈 의사결정 대부분이
   여기 있다).

---

# Role

PM / Solution Architect / Product Designer. Business 분석부터 Salesforce Object 설계
방향, 화면 UX까지 프로젝트 전체의 일관성을 지킨다.

---

# Responsibility

- Business Goal, Pain Point, Persona, Customer Journey 정의 및 유지(`00_STORY.md`)
- Domain Model과 Entity 정의, Salesforce Mapping 선택지 제시(`01_PROJECT.md`)
- 팀과 함께 큰 판단(Object 구조, MVP 범위 등)을 내리고 `05_DECISIONS.md`에 기록
- Fan 360 Dashboard / Fan Profile / Fan Timeline / Recommendation Panel의 UX 설계
- 문서 간 충돌이 없는지 확인 (CLAUDE.md §7 Source of Truth 원칙 유지)

---

# Deliverables

- `00_STORY.md`, `01_PROJECT.md`, `05_DECISIONS.md` (직접 작성·유지)
- `03_SYSTEM.md`, `02_TEAM_GUIDE.md`, `04_DEMO.md` (팀과 함께 검토·승인)
- 4개 핵심 화면(Fan 360 Dashboard, Fan Profile, Fan Timeline, Recommendation Panel)의
  UX 초안

---

# Owned Objects

직접 구축하지는 않지만, **모든 Object의 설계를 검토**한다 — 새 Object/Field가 필요할
때 "왜 필요한가"부터 확인하는 것이 Sara의 역할이다(01_PROJECT.md §3.4의 판단 기준 참고).

---

# Owned Flows

Flow 구축은 승우가 담당한다. Sara는 Flow의 **트리거 조건과 로직 설계**를 검토한다
(03_SYSTEM.md §4.2 Trigger → Action 표 유지·보완).

---

# Owned Screens

- Fan 360 Dashboard, Fan Profile, Fan Timeline, Recommendation Panel — UX 설계
  (구현·QA는 혜준, 데이터 연동은 승우와 협업 — `02_TEAM_GUIDE.md` §2 참고)

---

# Weekly Guide

### Week 1 — Foundation

- **이번 주 목표**: Business, Domain, Org 설계를 완성한다.
- **왜 이 작업을 하는가**: Salesforce 기능부터 시작하면 나중에 "왜 이 Object가
  필요한지" 설명할 수 없다(CLAUDE.md §3). 먼저 Business를 확정해야 팀 전체가 같은
  방향으로 움직인다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: `00_STORY.md`, `01_PROJECT.md`,
  `03_SYSTEM.md`, `05_DECISIONS.md`가 모두 팀의 동의를 얻은 상태.
- **누구와 협업해야 하는가**: 전체 팀(Object 구조 확정), 승우(Salesforce 구현 가능성
  검토).
- **먼저 읽어야 하는 문서**: `CLAUDE.md`, `00_STORY.md`.
- **추천 구현 순서**: Business Goal 확정 → Domain Model → Object 선택 → Field 설계.

### Week 2 — MVP Completion

- **이번 주 목표**: Object/Flow/화면/Demo가 실제로 동작하는 상태로 완성한다(목표:
  2026-08-14).
- **왜 이 작업을 하는가**: `02_TEAM_GUIDE.md` Phase 1 마감이다 — `main`이 항상 발표
  가능한 상태여야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 4개 핵심 화면이 실제 데이터로 동작,
  Demo Scene 4개(Core)가 리허설 가능한 상태.
- **누구와 협업해야 하는가**: 승우(Object/Flow 구현 진행 상황 확인), 혜준(화면 구현
  진행 상황 확인), 아론(Demo 시나리오 검증).
- **먼저 읽어야 하는 문서**: `04_DEMO.md`.
- **추천 구현 순서**: 화면 UX 확정 → 혜준의 화면 구현 리뷰 → Demo 리허설 참여.

### Week 3 — Future Scope

- **이번 주 목표**: MVP 이후 확장(예: 산리오 같은 협업사 시나리오)을 설계한다.
- **왜 이 작업을 하는가**: `05_DECISIONS.md` Decision 005로 미뤄둔 Sponsorship/
  Partnership Domain을 다시 꺼내볼 시점이다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 확장 시나리오 초안(Business
  관점에서).
- **누구와 협업해야 하는가**: 아론(Business Analyst 관점 함께 검토).
- **먼저 읽어야 하는 문서**: `05_DECISIONS.md` Decision 005.
- **추천 구현 순서**: Business 시나리오 정의 → Entity 재검토 → 필요 시 Object 제안.

### Week 4 — Polish

- **이번 주 목표**: QA 결과를 반영해 Dashboard/화면 UI를 다듬는다.
- **왜 이 작업을 하는가**: 발표 전 마지막으로 사용자(김매니저) 관점에서 화면이
  자연스러운지 확인해야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 혜준의 QA 피드백이 반영된 최종 화면.
- **누구와 협업해야 하는가**: 혜준(QA 결과 전달받기).
- **먼저 읽어야 하는 문서**: 없음 (QA 피드백 기반 작업).
- **추천 구현 순서**: QA 이슈 목록 검토 → 우선순위 판단 → UI 수정 요청.

### Week 5 — Presentation

- **이번 주 목표**: 최종 Demo와 발표 자료(PPT/포트폴리오)를 완성한다.
- **왜 이 작업을 하는가**: 프로젝트의 결과물을 명확하게 전달해야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 발표 가능한 최종 Demo, 발표 자료.
- **누구와 협업해야 하는가**: 아론(Demo 리허설 주도), 전체 팀(리허설 참여).
- **먼저 읽어야 하는 문서**: `04_DEMO.md`.
- **추천 구현 순서**: 발표 자료 초안 → 리허설 → 피드백 반영.

---

# Related Documents

- `CLAUDE.md` — 모든 결정의 기준이 되는 프로젝트 철학.
- `00_STORY.md` — Business Goal과 Persona를 직접 정의하는 문서.
- `01_PROJECT.md` — Domain Model과 Salesforce Mapping 선택지.
- `05_DECISIONS.md` — Sara가 이끈 의사결정의 기록.

---

# GitHub Projects

Task와 진행 상황은 GitHub Projects에서 관리한다.

---

# Learning Path

1. Business 이해: `00_STORY.md`의 Pain Point와 Persona부터 시작한다.
2. Customer 360 이해: "왜 데이터를 하나로 연결해야 하는가"를 `01_PROJECT.md` §5(Entity
   간 관계)로 익힌다.
3. Salesforce 구현 이해: `03_SYSTEM.md`의 Object 선택 근거(Person Account, Product2 등)를
   먼저 "왜"부터 읽는다 — Salesforce 용어를 외우기보다, 각 선택이 어떤 Business 문제를
   푸는지 이해하는 것이 먼저다.

---

# 🤝 협업 포인트

- **승우**: 새 Object/Field가 필요할 때, "왜 필요한가"를 먼저 함께 확인한 뒤 구현을
  요청한다.
- **은영**: Fan App에서 만드는 데이터가 Demo Story와 맞는지 함께 확인한다.
- **혜준**: QA 결과를 받아 화면 UX를 조정한다.
- **아론**: Demo Story와 화면 UX가 서로 자연스럽게 이어지는지 함께 검토한다.
