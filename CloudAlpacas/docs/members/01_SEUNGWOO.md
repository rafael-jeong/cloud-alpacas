# 승우

## [P2] Current Role

🎁 **Product + Quote + Campaign**. Salesforce Builder 역할(`02_TEAM_GUIDE.md §1`)은
유지하되, Phase 2에서는 B2B Sponsorship Sales의 "무엇을, 얼마에, 어떤 캠페인으로
실행하는가" 구간(Product/Quote/Campaign)을 End-to-End로 담당한다
(`02_TEAM_GUIDE.md §11`).

## [P2] Mission

Sponsorship Package(구장 광고, 전광판/펜스 광고, SNS 노출, Brand Day 등)를
Product2로 표현하고, 제안서를 **Standard Quote**로 관리하며, 필요 시
Collaboration 실행을 **Campaign Record Type**으로 표현해 구축한다
(`01_PROJECT.md §6.11`, `03_SYSTEM.md §7 C·D`, `05_DECISIONS.md` Decision 018-C·D).
대표 예시는 d'Alba(달바) Sponsorship 시나리오다(Decision 019,
`data/P2_DUMMY_DATA_MASTER.md §3`).

## [P2] Ownership

- **P1 Reuse**: Product2 / PricebookEntry(Ticket/Membership/Goods/Season Pass
  RecordType은 이미 존재) — Sponsorship Package는 이 위에 RecordType을 추가하는
  방식으로 확장
- **P2 확정**: Standard Quote/QuoteLineItem 사용(`§7 C`), Campaign에 Collaboration
  Record Type 추가(`§7 D`) — 별도 `Collaboration__c` Custom Object나 Lookup
  필드가 아니다
- **P2 신규 작업**: Sponsorship Package Product2 RecordType 신설, Quote 생성 흐름
  구축, Campaign Collaboration RecordType 신설

## [P2] End-to-End Responsibility

Requirement(Wireframe Opportunity Detail의 Product/Quote/Campaign) →
Business/Domain 이해(`01_PROJECT.md §6.11`) → Salesforce Object/Field(Quote/
Campaign RecordType 확정, 세부 Field는 구축하며 확인) → Admin → Demo Data →
Flow/Automation(필요 시) → Dev(필요 시) → 화면 → QA — 기존 Phase 1과 동일한
흐름을 Product/Quote/Campaign 영역에 적용한다.

## [P2] Shared Scenario

은영의 Opportunity가 진행되는 동안 **Product 라인업과 Standard Quote를 확정**하고,
**Campaign(Collaboration Record Type)으로 실행을 연결**한다(`02_TEAM_GUIDE.md §13`).

## [P2] Collaboration

- **은영**: Opportunity의 Product/Quote Related List가 정확히 연결되는지 확인한다.
- **사라**: Sponsorship Package가 Fan Insight의 Target Segment와 맞는지 확인한다.

## [P2] TBD / Decision Needed

Quote 사용 여부(C)와 Campaign RecordType vs Lookup(D)은 확정됐다. 남은 것은
구현 세부사항뿐이다.

- Sponsorship Package Product2 RecordType의 정확한 이름/필드
- Campaign Collaboration RecordType 신설 시, Org에 이미 존재하는 비활성
  RecordType(`Partner-Led Campaign`)을 재사용할지 새로 만들지 — Cloud Alpacas가
  만든 것인지 Salesforce 데모 템플릿인지 미확인이라 화요일 회의에서도 확정하지
  않았다

> 위 두 항목은 여전히 임의로 확정하지 않는다.

---

## [P1] Previous Role & Contribution

> Phase 1(B2C Fan 360 MVP)에서 승우가 실제로 수행한 역할과 기여를 보존한 History다.

# Mission

> **"설계된 Object와 Flow를 실제로 동작하는 Salesforce Org로 만든다."**

승우는 Cloud Alpacas의 Salesforce Builder다. **Salesforce 안의 데이터 구조를 만드는
사람** — 자동차에 비유하면 프레임과 엔진을 만드는 역할이다(02_TEAM_GUIDE.md §1-1). Sara와
아론이 확정한 Business Story를 실제 Object/Field/Flow로 Org에 구축하고, 팀이 "이 화면이
진짜 동작하네"라고 믿을 수 있게 만든다.

---

# Quick Start

1. `CLAUDE.md` — Baby Rule과 MVP 범위부터 확인한다.
2. `00_STORY.md` — 내가 만드는 Object가 어떤 Business 문제를 푸는지 감을 잡는다.
3. `03_SYSTEM.md` — **가장 많이 보게 될 문서.** Object/Field/ERD/Flow 설계가 모두 여기
   있다.
4. `05_DECISIONS.md` — Object를 왜 이렇게 설계했는지(특히 Decision 003~006)를 반드시
   읽는다 — "왜 Custom Object를 안 만들었지?" 같은 질문의 답이 여기 있다.

---

# Role

Salesforce Builder. Salesforce 안의 데이터 구조(Object/Field/Relationship)와 핵심
Business Flow를 실제로 만든다.

---

# Responsibility

- `03_SYSTEM.md`에 정의된 모든 Object/Field를 Salesforce Org에 구축
- Price Book/Price Book Entry로 Ticket Policy·Membership Tier 가격 설정
- Flow 구축 — Welcome Campaign Flow, VIP 후보 감지 Flow 등(03_SYSTEM.md §4)
- Slack 연동(Flow → Slack 알림 발송) 구축
- Person Account, Marketing Consent 필드 등 데이터 모델의 정확성 유지

---

# Deliverables

- 실제로 동작하는 Salesforce Org (`force-app/` 하위 Metadata)
- `03_SYSTEM.md` §4에 정의된 Flow 전체
- 4개 화면(Fan 360 Dashboard 등)이 정확한 데이터를 보여주도록 Object/Field 연동 지원
  (화면 자체의 구현은 혜준 담당)

---

# Owned Objects

- 표준: Person Account(Fan), Contact(Player), Product2, PricebookEntry, Order/
  OrderItem, Case
- Custom: `Game__c`, `Admission__c`, `Benefit__c`, `Notification_Log__c`,
  `Engagement_Signal__c`, `Attendance_Record__c`, `Fan_Activity_Pattern__c`,
  `Fan_Segment_History__c`, `Recommendation__c`

(`02_TEAM_GUIDE.md` §2 참고 — 이 배정은 제안 상태다.)

---

# Owned Flows

- Welcome Campaign Flow (03_SYSTEM.md §4.4)
- VIP 후보 감지 Flow (03_SYSTEM.md §4.5)
- §4.2 Trigger → Action 표의 나머지 Flow(First Ticket Campaign, First Visit Guide,
  First Merchandise Campaign, Favorite Player Campaign 등)

---

# Owned Screens

해당 없음 — 화면 구현은 혜준(Salesforce Experience Lead)이 담당한다(02_TEAM_GUIDE.md
§2). 승우는 화면이 참조하는 Object/Field가 정확한 데이터를 갖도록 뒷받침한다.

---

# Weekly Guide

### Week 1 — Foundation

- **이번 주 목표**: Org 기본 설정과 핵심 Object(Person Account, Product2, Order)를
  먼저 구축한다.
- **왜 이 작업을 하는가**: 나머지 모든 Custom Object(Admission, Recommendation 등)가
  이 세 Object를 참조한다 — 순서가 중요하다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: Person Account 활성화, Product2 +
  Price Book 기본 데이터, Order/OrderItem 커스텀 필드.
- **누구와 협업해야 하는가**: Sara(설계 확인), 혜준(Sandbox 환경 준비).
- **먼저 읽어야 하는 문서**: `03_SYSTEM.md` §2.1~2.4.
- **추천 구현 순서**: Person Account 활성화 → Product2/PricebookEntry → Order/
  OrderItem 커스텀 필드.

### Week 2 — MVP Completion

- **이번 주 목표**: 나머지 Custom Object와 Flow를 모두 구축한다(목표: 2026-08-14).
- **왜 이 작업을 하는가**: `02_TEAM_GUIDE.md` Phase 1 마감 — Demo가 실제로 동작해야
  한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: `03_SYSTEM.md` §1.2의 Custom
  Object 9개, §4의 Flow 전체, 4개 화면이 필요로 하는 데이터 연동.
- **누구와 협업해야 하는가**: 은영(Fan App 연동 테스트), 혜준(화면 구현·QA), 아론
  (Sample Data 적재).
- **먼저 읽어야 하는 문서**: `03_SYSTEM.md` §3(ERD), §4(Flow).
- **추천 구현 순서**: Custom Object 구축 → Flow 구축 → Slack 연동 → 혜준과 화면
  데이터 연동 확인 → Sample Data로 End-to-End 테스트.

### Week 3 — Future Scope

- **이번 주 목표**: Sara·아론이 설계한 확장 시나리오(예: Sponsorship)의 구현
  가능성을 검토한다.
- **왜 이 작업을 하는가**: MVP가 끝난 뒤에도 Object 구조가 확장 가능한지 확인해야
  한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 확장 Object에 대한 기술 검토
  의견.
- **누구와 협업해야 하는가**: Sara.
- **먼저 읽어야 하는 문서**: `05_DECISIONS.md` Decision 005.
- **추천 구현 순서**: 확장 시나리오 검토 → 필요 시 프로토타입 Object 구성.

### Week 4 — Polish

- **이번 주 목표**: 혜준의 QA 피드백을 반영해 Flow/Object를 다듬는다.
- **왜 이 작업을 하는가**: 발표 전 오류·엣지 케이스를 줄여야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: QA 이슈가 반영된 안정적인 Org.
- **누구와 협업해야 하는가**: 혜준.
- **먼저 읽어야 하는 문서**: 없음(QA 이슈 기반).
- **추천 구현 순서**: QA 이슈 목록 확인 → 우선순위대로 수정 → 재검증.

### Week 5 — Presentation

- **이번 주 목표**: Demo 리허설을 함께 진행하고, 라이브 클릭 시나리오를 안정화한다.
- **왜 이 작업을 하는가**: Demo 당일 실수 없이 진행되어야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 안정적으로 재현 가능한 라이브
  클릭 시나리오, 백업 녹화 영상 지원.
- **누구와 협업해야 하는가**: 아론(Demo 리허설), 혜준(백업 환경 점검).
- **먼저 읽어야 하는 문서**: `04_DEMO.md`.
- **추천 구현 순서**: 리허설 참여 → 발견된 이슈 즉시 수정.

---

# Related Documents

- `03_SYSTEM.md` — 매일 참고하는 핵심 문서.
- `05_DECISIONS.md` — Object 설계 근거.
- `02_TEAM_GUIDE.md` §2 — Object/Flow/Screen 담당 배정.

---

# GitHub Projects

Task와 진행 상황은 GitHub Projects에서 관리한다.

---

# Learning Path

1. Business 이해: `00_STORY.md`로 "왜 이 Object가 필요한지" 감을 먼저 잡는다.
2. Customer 360 이해: `01_PROJECT.md` §5(Entity 관계)로 Object들이 서로 어떻게
   연결되는지 이해한다.
3. Salesforce 구현: `03_SYSTEM.md`를 Object 하나씩 순서대로 구축하며 익힌다 — Person
   Account부터 시작해 Custom Object로 넘어가는 순서를 권장한다.

---

# 🤝 협업 포인트

- **Sara**: 새 Object/Field가 필요할 때 먼저 "왜 필요한가"를 확인한다.
- **은영**: Fan App이 만드는 이벤트(Admission, Engagement Signal 등)가 Salesforce에
  정확히 들어오는지 함께 테스트한다.
- **혜준**: Sandbox 환경과 QA 이슈를 주기적으로 공유받고, 혜준이 구현하는 화면이
  필요로 하는 Object/Field를 미리 맞춘다.
- **아론**: Sample Data를 언제, 어떤 형식으로 적재하면 되는지 미리 조율한다.
