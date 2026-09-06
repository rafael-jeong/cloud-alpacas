# members/ — 팀원 개인 온보딩 가이드

## 폴더 목적

이 폴더는 **팀원 개인의 Todo를 적는 공간이 아니다.**

각 팀원이 **자기 문서 하나만 읽고**

- 내가 왜 이 일을 하는지
- 무엇을 만들어야 하는지
- 어떤 순서로 진행하면 되는지
- 누구와 협업해야 하는지

를 이해할 수 있는 **개인 온보딩(Onboarding) 가이드**다.

우리 팀은 대부분 **Salesforce 프로젝트가 처음인 Baby Team**이다.

Salesforce Admin 경험도, Developer 경험도 많지 않으며, AI(ChatGPT, Claude Code 등)의 도움을 받아 함께 구현하는 프로젝트다.

따라서 이 문서는 **Salesforce를 잘 아는 사람**이 아니라 **프로젝트 첫날 참여한 팀원**을 기준으로 작성한다.

어려운 기술보다 **Business와 프로젝트의 흐름을 이해하는 것**을 우선하며, Salesforce는 그다음 단계에서 자연스럽게 익히도록 한다.

실제 **Task, 일정, Sprint, 진행 상황, Bug, Review**는 이 폴더가 아니라 **GitHub Projects**에서 관리한다.

"오늘 무엇을 해야 하지?"가 궁금하면 GitHub Projects를 확인한다.

이 폴더의 Weekly Guide는

> "이번 주가 끝났을 때 무엇이 완성되어 있어야 하는가"

를 안내하는 문서이지,

Task·체크리스트·진행률을 관리하는 문서는 아니다.

---

## 각 문서의 역할

| 문서 | 담당 |
|---|---|
| [`00_SARA.md`](./00_SARA.md) | Sara — PM / Solution Architect / Product Designer |
| [`01_SEUNGWOO.md`](./01_SEUNGWOO.md) | 승우 — Salesforce Builder |
| [`02_EUNYEONG.md`](./02_EUNYEONG.md) | 은영 — Developer Lead / Team Lead |
| [`03_HYEJUNE.md`](./03_HYEJUNE.md) | 혜준 — Salesforce Experience Lead / QA Lead |
| [`04_AARON.md`](./04_AARON.md) | 아론 — Business Analyst / Demo Experience Lead |

역할 정의 자체(누가 무엇을 담당하는가)의 유일한 진실(Single Source of Truth)은 **`02_TEAM_GUIDE.md`**이다.

이 폴더의 문서는 각자의 역할을

- 왜 하는지
- 어떤 Object를 담당하는지
- 어떤 Flow를 담당하는지
- 어떤 화면을 담당하는지
- 어떤 순서로 구현하면 되는지

를 개인 관점에서 풀어 설명한다.

역할이 변경되면 반드시 **`02_TEAM_GUIDE.md`**를 먼저 수정한 후, 각 팀원 문서를 맞춘다.

---

## 운영 방식 — GitHub Projects와의 역할 분리

| 구분 | 관리 위치 | 다루는 내용 |
|---|---|---|
| 설계 · 역할 · 온보딩 | `docs/` (이 폴더 포함) | Story, Domain, Workflow, Object, Screen, 팀 역할, "무엇을 왜 어떤 순서로 만드는가" |
| Task · Sprint · 진행 상황 · Bug · Review | **GitHub Projects** | 오늘 할 일, Sprint, 진행률, 버그, PR Review |

`docs/members/`는

> "내가 무엇을 책임지고, 왜, 어떤 순서로 만드는가"

까지만 설명한다.

> "오늘 무엇을 하고 있는가"

는 GitHub Projects가 관리한다.

---

## 관리 규칙

- **각자 자신의 문서만 수정한다.** 다른 팀원의 역할이 궁금하면 문서를 읽거나 직접 이야기한다.
- **이 폴더는 프로젝트의 Source of Truth가 아니다.** 설계가 변경되면 반드시 공식 문서를 먼저 수정한다.
- **Todo, Check List, Progress, Status는 절대 작성하지 않는다.** 모두 GitHub Projects에서 관리한다.
- **프로젝트 전체에 영향을 주는 변경 사항**(Business Goal, Object 구조, Workflow, 역할 변경, MVP 범위 변경 등)은 반드시 `05_DECISIONS.md`에 기록한다.
- 모든 팀원 문서는 동일한 템플릿을 사용한다. 섹션을 임의로 변경하지 않는다.

---

## [P1] 공통 템플릿 (Phase 1)

Phase 1(B2C Fan 360 MVP) 기간 동안 모든 멤버 문서가 따른 템플릿이다 — History로
보존한다. 각 멤버 문서 하단 `[P1] Previous Role & Contribution` 이하가 이 템플릿
그대로다.

```markdown
# Mission
# Quick Start
# Role
# Responsibility
# Deliverables
# Owned Objects
# Owned Flows
# Owned Screens
# Weekly Guide
  ### Week 1
  ### Week 2
  ### Week 3
  ### Week 4
  ### Week 5
# Related Documents
# GitHub Projects
# Learning Path
# 🤝 협업 포인트
```

---

## [P2] 공통 템플릿 (Phase 2)

Phase 2(B2C 고도화 + B2B Collaboration/Sponsorship Expansion)부터는 각 멤버
문서 **최상단**에 아래 템플릿을 추가한다 — Phase 1 템플릿을 대체하는 것이 아니라,
"지금 무엇을 담당하는가"를 먼저 보여주고 그 아래에 Phase 1 History를 그대로
이어붙이는 구조다.

```markdown
# [이름]

## [P2] Current Role
## [P2] Mission
## [P2] Ownership
## [P2] End-to-End Responsibility
## [P2] Shared Scenario
## [P2] Collaboration
## [P2] TBD / Decision Needed

---

## [P1] Previous Role & Contribution

(Phase 1 템플릿 전체를 그대로 보존)
```

`[P2] TBD / Decision Needed`는 `docs/decision_sheet/P2_TECHNICAL_DECISION_SHEET.md`의
화요일 회의 결과가 나오기 전까지는 임의로 채우지 않는다 — 확정된 기술 구조인
것처럼 쓰지 않는다.

---

Mission은

> **"내가 이 프로젝트에서 존재하는 이유"**

를 설명한다.

Role보다 먼저 읽는다.

---

Quick Start는

프로젝트에 처음 참여한 사람이

**어떤 문서를 어떤 순서로 읽으면 되는지**

안내한다.

---

Deliverables는

이번 프로젝트가 끝났을 때

**내가 최종적으로 완성해야 하는 결과물**이다.

---

Owned Objects / Flows / Screens는

내가 직접 설계하거나 구현을 책임지는 영역이다.

담당하지 않는 경우에는

"해당 없음" 또는

"설계만 담당"

처럼 명확하게 작성한다.

---

GitHub Projects 섹션에는 항상 아래 문장만 작성한다.

> **Task와 진행 상황은 GitHub Projects에서 관리한다.**

---

Weekly Guide는 `02_TEAM_GUIDE.md`의 Milestone을 기준으로 작성한다.

각 주차마다 아래 내용을 안내한다.

- 이번 주 목표
- 왜 이 작업을 하는가
- 이번 주가 끝났을 때 완성되어 있어야 하는 것
- 누구와 협업해야 하는가
- 먼저 읽어야 하는 문서
- 추천 구현 순서

Weekly Guide는 Task 체크리스트가 아니라

**추천 구현 순서와 학습 가이드**이다.

---

Related Documents는

단순히 문서를 나열하지 않는다.

각 문서를

**왜 읽어야 하는지**

함께 작성한다.

---

Learning Path는

Salesforce 기능을 외우는 순서가 아니라

Business를 이해하고

Customer 360을 이해한 뒤

Salesforce 구현으로 이어지는 추천 학습 순서를 작성한다.

---

🤝 협업 포인트는 문서의 마지막 섹션이다.

다른 팀원과

언제,

무엇을,

왜 협업해야 하는지

한 줄씩 정리한다.

---

## Related Documents

- `../00_STORY.md` — 프로젝트가 해결하려는 문제와 Customer 360의 목적을 이해한다.
- `../01_PROJECT.md` — Persona, Domain, Workflow, Business 전체를 이해한다.
- `../02_TEAM_GUIDE.md` — 팀 역할, 운영 방식, GitHub Projects, Milestone을 확인한다.
- `../03_SYSTEM.md` — Salesforce Object, Architecture, ERD, Flow를 이해한다.
- `../04_DEMO.md` — Demo Story와 발표 흐름을 이해한다.
- `../05_DECISIONS.md` — 프로젝트 전체에 영향을 주는 의사결정 기록을 확인한다.