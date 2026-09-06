# 아론

## [P2] Current Role

🏢 **Account + Contact**. Business Analyst / Demo Experience Lead 역할
(`02_TEAM_GUIDE.md §1`)은 유지하되, Phase 2에서는 **공식 관계가 형성된 파트너사
정보(Account)와 담당자(Contact)** 영역을 End-to-End로 담당한다
(`02_TEAM_GUIDE.md §11`) — Demo Story/Data 기획 역할도 계속 유지한다.

## [P2] Mission

Lead가 전환된 이후의 스폰서사 정보(Account)와 담당자(Contact)를 관리하고,
Sponsorship 현황(Active Collaboration/Total Collab Value — 필드명은 On Hold)이
한눈에 보이도록 만든다(`01_PROJECT.md §6.1`, `03_SYSTEM.md §7 K`). 대표 예시는
d'Alba(달바)다(`05_DECISIONS.md` Decision 019, `data/P2_DUMMY_DATA_MASTER.md §3`).

## [P2] Ownership

- Account(Sponsor/Partner RecordType)
- Contact(Partner Contact RecordType)
- Account 집계 필드(Active Collaboration/Total Collab Value) — **On Hold**로
  확정(`03_SYSTEM.md §7 K`, `05_DECISIONS.md` Decision 018-K) — Roll-up 가능
  여부 기술 확인 전까지는 구현하지 않는다. Demo에서 이 집계에 의존하는 화면은
  없다(`04_DEMO.md §9`)
- `04_DEMO.md`/`docs/data/DEMO_DATA_STANDARD.md` — Demo Story/Data 기획은
  계속 유지

## [P2] End-to-End Responsibility

Requirement(Wireframe Account 화면) → Business/Domain 이해(`01_PROJECT.md §6.2`
Fan Person Account와의 공존 이슈 포함) → Salesforce Object/Field(Account/Contact는
Standard 확정, 집계 필드는 TBD) → Admin → Demo Data → Flow/Automation(필요 시) →
Dev(필요 시) → 화면 → QA

## [P2] Shared Scenario

혜준의 Lead Convert 결과를 받아 Account/Contact를 관리하고, 은영의 Opportunity에
연결한다(`02_TEAM_GUIDE.md §13`).

## [P2] Collaboration

- **혜준**: Lead→Account 전환 시점을 맞춘다.
- **은영**: Account 하위 Opportunity가 정확히 연결되는지 확인한다.
- **사라**: Demo Data 규모(`04_DEMO.md §10`) 조율은 Phase 1과 동일하게 계속한다.

## [P2] TBD / Decision Needed

- Account 집계 필드(`03_SYSTEM.md §7 K`) — 2026-08-18 회의에서 **On Hold로
  확정**됐다. Opportunity-Account가 표준 Lookup 관계라 Roll-up 가능 여부
  기술 확인이 아직 남아 있어, Option A(Roll-up)/B(Report) 중 하나를 임의로
  선택하지 않는다.

> 다음 회의에서 기술 확인 결과가 나올 때까지 이 항목은 계속 TBD다.

---

## [P1] Previous Role & Contribution

> Phase 1(B2C Fan 360 MVP)에서 아론이 실제로 수행한 역할과 기여를 보존한 History다.

# Mission

> **"이루키의 이야기가 청중에게 설득력 있게 전달되도록 만든다."**

아론은 Cloud Alpacas의 Business Analyst / Demo Experience Lead다. 완성된 결과를
검사하는 사람이 아니라, **Sara와 함께 Customer Journey를 설계하고, Business Story를
다듬으며, Demo가 가장 자연스럽게 전달되도록 만드는 사람**이다(02_TEAM_GUIDE.md §1).
Object나 Field를 먼저 찾지 않고, Business Story를 먼저 만들고 그 Story에 필요한
Object를 함께 찾는다 — CLAUDE.md §3 Business First 철학을 가장 앞장서서 실천하는
역할이다.

---

# Quick Start

1. `00_STORY.md` — Persona(김매니저·이루키)와 Pain Point를 가장 먼저, 가장 깊게
   이해해야 하는 문서.
2. `04_DEMO.md` — 직접 작성·운영하는 핵심 문서. Scene 구조와 화면 목록을 숙지한다.
3. `03_SYSTEM.md` §2 — Sample Data를 기획하려면 각 Object에 어떤 Field가 있는지
   알아야 한다.
4. `02_TEAM_GUIDE.md` §2 — Sample/Dummy Data 담당임을 확인한다.

---

# Role

Business Analyst / Demo Experience Lead. Customer Journey와 Business Story를
설계하고, 그 Story가 Demo Experience로 자연스럽게 이어지도록 만든다.

---

# Responsibility

- Happy Path 설계 — 이루키가 신규 팬에서 충성 팬으로 성장하는 여정을 구체적인
  단계로 정리
- Business Story 보완, Business Flow 검토 — Sara가 정리한 Domain Model이 실제
  이야기와 맞는지 함께 확인
- `04_DEMO.md`의 Scene 구조와 발표 시나리오(멘트 포함) 작성·유지, Demo Experience 설계
- `docs/data/SAMPLE_DATA.md`, `docs/data/DEMO_DATASETS.md`의 실제 더미 데이터 기획
- Recommendation·Notification Log의 문구(어떤 메시지를 보낼지) 기획
- 발표 리허설 주도

---

# Deliverables

- `04_DEMO.md` (Scene별 시나리오)
- `docs/data/SAMPLE_DATA.md`, `docs/data/DEMO_DATASETS.md`
- 발표 대본(리허설을 거쳐 다듬어진 최종 멘트)

---

# Owned Objects

Object를 직접 구축하지는 않지만(승우 담당), 아래는 **콘텐츠·데이터 기획**을 책임진다.

- `Recommendation__c` — 추천 문구·로직 기획(승우와 협업)
- `Notification_Log__c` — 발송 콘텐츠 기획
- Sample Data 전체 (`docs/data/`)

---

# Owned Flows

해당 없음 — Flow 구축은 승우 담당이다. 다만 Flow가 실행됐을 때 나오는 **결과 문구**
(Recommendation 사유, Notification 내용, Slack 메시지)는 아론이 기획한다.

---

# Owned Screens

Recommendation Panel의 **문구·콘텐츠** — 화면 UX는 Sara, 구현은 혜준, 문구는 아론.

---

# Weekly Guide

### Week 1 — Foundation

- **이번 주 목표**: Demo Story의 뼈대(Scene 구조)를 Sara·전체 팀과 함께 확정한다.
- **왜 이 작업을 하는가**: Demo 구조가 먼저 정해져야, 어떤 Sample Data가 필요한지
  알 수 있다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: `04_DEMO.md` 초안.
- **누구와 협업해야 하는가**: Sara(Business 관점 정합성 확인).
- **먼저 읽어야 하는 문서**: `00_STORY.md`.
- **추천 구현 순서**: Customer Journey 확인 → Scene 목록 작성 → 화면 목록과 매칭.

### Week 2 — MVP Completion

- **이번 주 목표**: Sample Data를 실제로 만들고, Demo Scene을 리허설 가능한 상태로
  만든다(목표: 2026-08-14).
- **왜 이 작업을 하는가**: `02_TEAM_GUIDE.md` Phase 1 마감 — Demo가 실제 데이터로
  동작해야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: `docs/data/`의 실제 값 완성,
  Core Scene 4개 리허설 1회 이상 완료.
- **누구와 협업해야 하는가**: 승우(데이터 적재), 은영(Fan App 이벤트와 맞추기),
  혜준(데이터 검증).
- **먼저 읽어야 하는 문서**: `04_DEMO.md` §5(Sample Data 요구사항).
- **추천 구현 순서**: 필요 데이터 목록 확정 → 실제 값 작성 → 적재 → 리허설.

### Week 3 — Future Scope

- **이번 주 목표**: 확장 시나리오(예: 산리오 협업)를 Business 관점에서 함께
  구체화한다.
- **왜 이 작업을 하는가**: `05_DECISIONS.md` Decision 005로 미뤄둔 부분을 다음
  단계로 이어가야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 확장 시나리오 스토리 초안.
- **누구와 협업해야 하는가**: Sara.
- **먼저 읽어야 하는 문서**: `05_DECISIONS.md` Decision 005.
- **추천 구현 순서**: 시나리오 브레인스토밍 → Sara와 Entity 영향 검토.

### Week 4 — Polish

- **이번 주 목표**: 발표 멘트를 다듬고, QA 결과에 맞춰 Demo Scene을 조정한다.
- **왜 이 작업을 하는가**: 리허설에서 나온 어색한 지점을 매끄럽게 고쳐야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 다듬어진 발표 대본.
- **누구와 협업해야 하는가**: 혜준(QA 이슈 반영), Sara(화면 UI 변경 사항 반영).
- **먼저 읽어야 하는 문서**: 없음(리허설 피드백 기반).
- **추천 구현 순서**: 리허설 → 피드백 수집 → 대본·Scene 수정.

### Week 5 — Presentation

- **이번 주 목표**: 최종 Demo와 PPT/포트폴리오를 완성하고 발표를 주도한다.
- **왜 이 작업을 하는가**: 프로젝트의 최종 결과물을 전달하는 마지막 단계다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 발표 가능한 최종 Demo, 발표
  자료.
- **누구와 협업해야 하는가**: 전체 팀(최종 리허설).
- **먼저 읽어야 하는 문서**: `04_DEMO.md`.
- **추천 구현 순서**: 최종 리허설 → 시간 조정(5분/10분) → 발표.

---

# Related Documents

- `00_STORY.md` — Demo Story의 원본 서사.
- `04_DEMO.md` — 직접 작성·운영하는 핵심 문서.
- `docs/data/` — Sample/Dummy Data.

---

# GitHub Projects

Task와 진행 상황은 GitHub Projects에서 관리한다.

---

# Learning Path

1. Business 이해: `00_STORY.md`의 Pain Point와 Persona를 발표할 수 있을 정도로
   깊게 이해한다.
2. Customer 360 이해: `03_SYSTEM.md` §3(ERD)으로 데이터가 어떻게 연결되는지 알아야
   Sample Data를 앞뒤가 맞게 기획할 수 있다.
3. Salesforce 구현: Demo에서 클릭할 화면의 실제 동작을 혜준과 함께 미리 손에 익힌다.

---

# 🤝 협업 포인트

- **Sara**: Demo Story가 Business Goal과 어긋나지 않는지 함께 확인한다.
- **승우**: Sample Data를 언제, 어떤 형식으로 전달하면 되는지 조율한다.
- **은영**: Fan App 영상 소재와 Salesforce 라이브 파트가 자연스럽게 이어지는지
  확인한다.
- **혜준**: 리허설 중 발견된 이슈를 공유받아 시나리오에 반영한다.
