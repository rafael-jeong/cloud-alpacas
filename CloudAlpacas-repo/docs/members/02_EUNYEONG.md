# 은영

## [P2] Current Role

💼 **Opportunity**. Developer Lead 역할(`02_TEAM_GUIDE.md §1`)은 유지하되, Phase 2
에서는 B2B Sponsorship Sales의 핵심 파이프라인인 **Opportunity**를 End-to-End로
담당한다(`02_TEAM_GUIDE.md §11`) — Phase 1에서 Fan App 개발에 쏠려 있던 비중이
Opportunity 영역으로 확장된다.

## [P2] Mission

Lead가 Account/Contact로 전환된 뒤 실제 Sponsorship 거래(Opportunity, 예:
Advertising Sponsorship)가 Stage를 따라 진행되고, Expected Benefit→
Sponsorship Package/Quote→Closed Won→Pipeline/Revenue Dashboard까지
자연스럽게 이어지도록 만든다(`00_STORY.md §8.3`, `03_SYSTEM.md §7`,
`05_DECISIONS.md` Decision 019). 계약 이후 실제 Performance 분석은 Future
Scope다(`00_STORY.md §8.4`).

## [P2] Ownership

- **P1/Standard Reuse**: Opportunity(Stage Kanban, Amount/CloseDate/Probability) —
  Standard Object 그대로 사용
- **P2 확정**: Expected Benefit 필드 — **단기/중기/장기 3개 필드로 분리**
  (`03_SYSTEM.md §7 F`, `05_DECISIONS.md` Decision 018-F). 정확한 API Name은
  아직 미확정(TBD) — Org 반영 시 확정
- Target Segment(Picklist, `§7 G`, 값 목록 TBD)도 Opportunity에 함께 들어간다
- OpportunityLineItem(Product 연결, 승우 협업)

## [P2] End-to-End Responsibility

Requirement(Wireframe Opportunity Detail/Stage Kanban) → Business/Domain
이해(`01_PROJECT.md §8`) → Salesforce Object/Field(Opportunity는 Standard 확정,
Expected Benefit은 3개 필드 구조로 확정·API Name만 TBD) → Admin → Demo Data →
Flow/Automation(필요 시) → Dev(필요 시) → 화면 → QA

## [P2] Shared Scenario

아론의 Account/Contact 전환 직후 Opportunity를 생성·진행하고, 승우의
Product/Quote/Campaign과 연결하며, 최종적으로 Performance/장기 Partnership
판단으로 넘긴다(`02_TEAM_GUIDE.md §13`).

## [P2] Collaboration

- **아론**: Account/Contact 전환 시점에 Opportunity가 생성되는 흐름을 맞춘다.
- **승우**: Opportunity에 Product/Quote/Campaign이 연결되는 구조를 함께 정한다.
- **사라**: Target Segment 필드가 Opportunity에 어떻게 들어가는지 확인한다.

## [P2] TBD / Decision Needed

Expected Benefit 필드 구조(F)와 Target Segment 저장 방식(G)은 확정됐다
(`05_DECISIONS.md` Decision 018-F·G). 남은 것은 세부 값뿐이다.

- Expected Benefit 3개 필드의 정확한 API Name
- Target Segment Picklist의 실제 값 목록(사라·혜준과 공동)

> 위 두 항목은 여전히 임의로 확정하지 않는다.

---

## [P1] Previous Role & Contribution

> Phase 1(B2C Fan 360 MVP)에서 은영이 실제로 수행한 역할과 기여를 보존한 History다.

# Mission

> **"표준 기능으로 안 되는 모든 것을, 코드로 만들어 실제로 동작하게 한다."**

은영은 Cloud Alpacas의 **Developer Lead**다. 설계된 Customer 360을 실제로 동작하는
제품으로 만드는 사람 — Demo Fan App, 그리고 Salesforce 표준 기능만으로 해결이 안
되는 화면 부품(LWC)과 로직(Apex), 외부 시스템 연동(Slack 등)을 코드로 만든다.
동시에 팀 전체의 개발 일정을 조율한다.

**원칙은 하나다: Salesforce 표준 기능을 먼저 쓰고, 표준으로 안 될 때만
개발한다.** Decision 003이 Object 설계에 적용한 "Standard First, Custom When
Needed" 원칙을 코드 레벨까지 그대로 확장한 것이다(Decision 008).

---

# Quick Start

1. `CLAUDE.md` §5, §6 — Fan App이 "이번 프로젝트의 주인공이 아니라 Demo용
   채널"이라는 점, 그리고 Agentforce가 이번 MVP 범위 밖이라는 점을 먼저
   확인한다.
2. `00_STORY.md` §5 — 이루키의 Customer Journey가 곧 Fan App이 만들어야 할
   이벤트 목록이다.
3. `05_DECISIONS.md` Decision 003, 008 — "언제 표준으로 충분하고, 언제 직접
   개발해야 하는가"의 판단 기준.
4. `03_SYSTEM.md` §2, §4.6 — Fan App 이벤트가 들어갈 Object, 그리고 아직
   누가 계산할지 정해지지 않은 로직(Apex 후보)을 확인한다.
5. `02_TEAM_GUIDE.md` §2 — Repository 구조와 담당 범위를 확인한다.

---

# Role

Developer Lead. Salesforce 표준 기능으로 해결되지 않는 부분(Fan App, LWC, Apex,
외부 연동)을 코드로 만든다. 팀 개발 일정도 조율한다.

---

# Responsibility

- `cloudalpacas-fan-app` 개발 (로그인, 티켓 구매, 굿즈 구매, QR 체크인 등)
- LWC 개발 — **표준 컴포넌트로 부족할 때만** (Recommendation Panel, Fan Timeline
  등에 들어가는 위젯)
- Apex 개발 — **Flow로 안 되는 복잡한 로직만** (`03_SYSTEM.md` §4.6 후보 참고)
- Salesforce API 연동 (Fan App → Salesforce 데이터 전달)
- Slack 연동 아키텍처 (App/Webhook 설정, 메시지 Payload 형식)
- 🔵 Agentforce (Fan Summary, Next Best Action 설명 등) — CLAUDE.md §5에 따라
  이번 MVP 범위 밖. 지금 만들지 않는다
- 팀 전체 개발 일정 조율 (`02_TEAM_GUIDE.md` §8)

---

# Deliverables

- `cloudalpacas-fan-app` 저장소(Demo용 이벤트 생성기)
- Fan App ↔ Salesforce 연동 가이드(API 또는 Dummy Data 주입 방식)
- 필요해진 경우에만: LWC 컴포넌트, Apex 클래스, Slack 연동 설정 문서

---

# Owned Objects

Object를 직접 구축하지는 않지만(승우 담당), 아래 Object에 **데이터를 채우는 연동**을
책임진다.

- `Admission__c` (체크인 이벤트)
- `Engagement_Signal__c` (SNS 반응 이벤트)
- Order/OrderItem (티켓·굿즈 구매 이벤트)

---

# Owned Flows

해당 없음 — Flow 구축은 승우 담당이다. 다만 **Flow가 감당하지 못하는 복잡한
로직**은 은영이 Apex로 만든다(표준 우선 원칙 — `03_SYSTEM.md` §4.6에 이미 후보로
기록된 항목이 실제 대상이다). 무엇을 Flow로 두고 무엇을 Apex로 옮길지는 승우와
함께 판단한다.

---

# Owned Screens

Customer 360 화면(Lightning Page 레이아웃) 자체는 해당 없음 — 혜준(Salesforce
Experience Lead) 담당이다. 다만 **표준 컴포넌트로 부족한 부분**은 은영이 LWC로
코드를 만들고, 혜준이 그 부품을 화면에 조립한다(예: Recommendation Panel의 커스텀
카드, VIP Badge). Fan App 화면은 Customer 360이 아니라 Demo용 영상 소재다
(04_DEMO.md §1).

---

# Weekly Guide

### Week 1 — Foundation

- **이번 주 목표**: `cloudalpacas-fan-app` 저장소를 만들고, 이루키의 Customer
  Journey에 맞는 이벤트 목록을 정리한다.
- **왜 이 작업을 하는가**: Salesforce Object 설계(승우)와 Fan App 이벤트 설계가
  서로 맞아야 나중에 연동이 매끄럽다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: Fan App 저장소 초기 세팅, 이벤트
  목록 초안.
- **누구와 협업해야 하는가**: 승우(Object/Field 이름 맞추기).
- **먼저 읽어야 하는 문서**: `00_STORY.md` §5, `03_SYSTEM.md` §2.
- **추천 구현 순서**: 이벤트 목록 정리 → 저장소 초기 세팅 → 화면 없이 이벤트 생성
  로직부터.

### Week 2 — MVP Completion

- **이번 주 목표**: Fan App에서 만든 이벤트가 Salesforce에 정확히 들어가는 것까지
  완성한다(목표: 2026-08-14). Flow만으로 안 되는 부분이 있다면 승우와 함께 Apex
  필요 여부를 판단한다(`03_SYSTEM.md` §4.6).
- **왜 이 작업을 하는가**: Demo Scene(04_DEMO.md)이 실제 데이터를 기반으로 재현되어야
  한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 8개 Scene에 필요한 이벤트가 모두
  Fan App → Salesforce로 연결된 상태. Slack 연동 아키텍처(App/Webhook) 완료.
- **누구와 협업해야 하는가**: 승우(연동 테스트, Flow-Apex 경계 판단), 혜준(표준
  컴포넌트로 부족한 화면 요소가 있으면 LWC 필요 여부 협의), 아론(Demo Scene 순서
  확인).
- **먼저 읽어야 하는 문서**: `04_DEMO.md` §3(Scene 상세), `03_SYSTEM.md` §4.6.
- **추천 구현 순서**: 이벤트 생성 로직 완성 → 승우와 연동 테스트 → Slack 연동
  → (필요시) LWC/Apex 개발 → 영상 촬영용 화면 정리.

### Week 3 — Future Scope

- **이번 주 목표**: 확장 시나리오(Sponsorship 등)에 필요한 이벤트가 있는지
  검토하고, Agentforce로 확장한다면 어떤 형태일지 초안을 그려본다.
- **왜 이 작업을 하는가**: MVP 이후 방향을 팀과 맞춘다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 필요 시 이벤트 확장 초안,
  Agentforce 활용 아이디어 메모(구현 아님).
- **누구와 협업해야 하는가**: Sara.
- **먼저 읽어야 하는 문서**: `05_DECISIONS.md` Decision 005, 008.
- **추천 구현 순서**: Sara·아론의 시나리오 논의에 참여 후 필요한 이벤트만 추가.

### Week 4 — Polish

- **이번 주 목표**: 혜준의 QA 피드백을 반영해 이벤트 데이터 품질을 다듬는다.
- **왜 이 작업을 하는가**: 잘못된 데이터(예: 시간 역전)가 Demo에서 어색하게 보이지
  않도록 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: QA를 통과한 이벤트 데이터.
- **누구와 협업해야 하는가**: 혜준.
- **먼저 읽어야 하는 문서**: 없음(QA 이슈 기반).
- **추천 구현 순서**: QA 이슈 확인 → 이벤트 생성 로직 수정 → 재검증.

### Week 5 — Presentation

- **이번 주 목표**: Fan App 영상 소재를 최종 촬영·편집하고 Demo 리허설에 참여한다.
- **왜 이 작업을 하는가**: 04_DEMO.md의 각 Scene 영상 파트가 매끄럽게 이어져야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: Scene별 영상 소재 완성.
- **누구와 협업해야 하는가**: 아론(Demo 리허설 주도).
- **먼저 읽어야 하는 문서**: `04_DEMO.md`.
- **추천 구현 순서**: 영상 촬영 → 편집 → 리허설에서 라이브 클릭과 이어 재생 테스트.

---

# Related Documents

- `00_STORY.md` §5 — Fan App이 재현해야 할 Customer Journey.
- `03_SYSTEM.md` §2, §4.6 — 이벤트가 들어갈 Object/Field, 그리고 Apex 후보.
- `05_DECISIONS.md` Decision 003, 008 — "표준 우선, 필요할 때만 개발" 판단 기준.
- `04_DEMO.md` — Fan App 영상 파트가 필요한 Scene 목록.

---

# GitHub Projects

Task와 진행 상황은 GitHub Projects에서 관리한다.

---

# Learning Path

1. Business 이해: `00_STORY.md`의 Customer Journey를 이벤트 목록으로 바꿔본다.
2. 판단 기준 이해: `05_DECISIONS.md` Decision 003·008로 "언제 표준으로 충분하고
   언제 직접 개발해야 하는지"부터 익힌다 — LWC/Apex를 배우기 전에 먼저 잡아야
   하는 감각이다.
3. Customer 360 이해: 내가 만든 이벤트가 Fan Timeline에서 어떻게 보이는지
   `03_SYSTEM.md` §3(ERD)로 확인한다.
4. Salesforce 구현: Salesforce API 연동 기초(Object에 레코드를 만드는 방법)를
   승우와 함께 익힌다.

---

# 🤝 협업 포인트

- **승우**: Object/Field API 이름을 맞추고, Flow와 Apex의 경계(무엇을 Flow로
  두고 무엇을 Apex로 옮길지)를 함께 판단한다.
- **Sara**: Fan App이 재현하는 이야기가 Demo Story와 어긋나지 않는지 확인한다.
- **혜준**: 표준 컴포넌트로 부족한 화면 요소가 있으면 LWC로 만들어 전달하고,
  생성된 이벤트 데이터의 정합성(날짜 순서 등)을 함께 검증한다.
- **아론**: Demo Scene에 맞는 영상 소재 요구사항을 전달받는다.
