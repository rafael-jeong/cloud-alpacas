# 혜준

## [P2] Current Role

🔎 **Collab360 + Lead**. Salesforce Experience Lead / QA Lead 역할
(`02_TEAM_GUIDE.md §1`)에서, Phase 2에서는 **Partner Candidate Discovery(Collab360)와
Lead 영역을 End-to-End로 담당**한다(`02_TEAM_GUIDE.md §11`) — 화면·데이터·QA를
모두 아우르는 역할로 확장된다.

## [P2] Mission

기업 DB(약 100개)를 대상으로 한 Agentforce Matching/Top 10 추천 화면(Collab360)과,
실제 Outbound 영업 파이프라인 진입점인 Lead를 설계하고 구축한다(`00_STORY.md §8.3`,
`01_PROJECT.md §2.7`). 2026-08-18 Technical Decision 회의로 이 영역의 핵심 결정
(A/B/E/H/I) 5개 전부 확정됐고(`05_DECISIONS.md` Decision 017·018), 같은 날 이후
멘토링으로 대표 시나리오가 **d'Alba(달바)**로, 중심축이 **Sponsorship Sales
Pipeline**으로 갱신됐다(Decision 019) — 이제 설계 판단보다 실제 구축이 중심이다.

## [P2] Ownership

- **확정**: Partner Candidate는 별도 Object가 아니라 **Lead로 흡수** —
  Lead Status를 세분화해 후보/접촉/검토/Qualified 단계까지 표현(`§7 A`, Decision
  018-A). 정확한 Status Picklist Label은 TBD
- **확정**: Lead Score = 신규 `Lead_Score__c`(Number) 필드(`§7 E`, Decision
  018-E) — 표준 `Rating`을 대체하는 것이 아니라 별개 필드
- **확정**: AI Matching = **Agentforce**(`§7 B`, Decision 017) — Rule-based나
  Demo Sample이 아니다. 기업 DB(약 100개)를 대상으로 Top 10을 추천한다. 혜준
  파트의 자동화 구현 영역
- **확정**: Segment Match = Agentforce Matching(`§7 H`), Recommendation Reason
  = Agentforce 결과 기반 자동 생성 Long Text(`§7 I`) — 둘 다 B의 Agentforce
  구현에 종속
- **확정(2026-08-19, Decision 020)**: 기업 DB(약 100개)는 Salesforce Object가
  아니다 — Agentforce Matching의 External Input/Data Source로만 쓰이고, 100개
  전체를 Lead로 만들지 않는다. **Primary Data Source는 DART Open API**로 확정 —
  CSV는 기본 저장 방식이 아니라 필요할 때만 쓰는 개발/테스트용 대체 입력
  (Optional)일 뿐이다. Agentforce 출력인 Top 10 Recommendation도 Object가 아니고
  반드시 DB에 저장해야 하는 레코드로 정의하지 않으며, 아직 Lead가 아니다 — 이 중
  담당자가 실제 영업 대상으로 선택한 기업만 Lead가 된다(DART Open API → 약 100개
  기업 조회 → Agentforce Matching → Top 10 Recommendation → 담당자가 기업 선택 →
  선택된 기업만 Lead)
- **TBD(상세 구현)**: Agentforce의 실제 구성(프롬프트/데이터 소스/평가 기준),
  Lead Status Picklist Label, **DART Open API의 실제 Salesforce/Agentforce
  연동 기술 방식(커넥터/Apex 콜아웃/External Object 등)** — 이번 회의는
  "무엇을 쓸지"만 확정했고 "어떻게 구성할지"는 아직이다

> **⚠️ 가장 중요한 구분 — Agentforce Fit/Recommendation Score ≠ `Lead_Score__c`**
> (2026-08-18 멘토링, Decision 019). 혜준이 직접 다루는 두 값이 서로 다른
> 개념이라는 점을 항상 구분해야 한다.
>
> | | Agentforce Fit/Recommendation Score | `Lead_Score__c` |
> |---|---|---|
> | 질문 | 팬덤과 이 기업이 잘 맞는가? | 이 Lead가 실제 계약까지 이어질 가능성이 높은가? |
> | 근거 | Fan 360 데이터(Segment Match 등) | 담당자 권한, 접촉 이력, 미팅 반응, 예산 등 |
> | 산출 시점 | Lead가 되기 전(기업 DB 추천 단계) | Lead가 된 이후(Qualification 단계) |
>
> 예: d'Alba는 Agentforce Fit Score 92(예시)로 추천됐지만, 실제 Outbound 접촉 후
> `Lead_Score__c`는 78(예시)일 수 있다 — 두 값을 하나로 합치거나 같은 필드에 넣지 않는다.

## [P2] End-to-End Responsibility

Requirement(Wireframe Collab360/Lead 화면) → Business/Domain 이해
(`01_PROJECT.md §2.7`) → Salesforce Object/Field(Lead 확정, `Lead_Score__c`
확정 — Status Label만 TBD) → Admin → Demo Data → Flow/Automation(Agentforce
구성 TBD) → Dev(LWC 필요 시, TBD) → 화면 → QA — Phase 1에서는 QA 비중이
컸다면, Phase 2에서는 Requirement/Data/Automation까지 직접 담당하는 것이
가장 큰 차이다.

## [P2] Shared Scenario

사라의 Fan Insight를 받아, 기업 DB(External Input, 약 100개)를 대상으로 Agentforce
Matching → Top 10 Recommendation을 만든다. 이 Top 10은 아직 Lead가 아니다 — 이 중
실제 Outbound 대상으로 **선정된 기업만** Lead(Status로 Candidate 단계 표현)에 등록한
뒤 아론에게 넘긴다(Lead Convert, `02_TEAM_GUIDE.md §13`).

## [P2] Collaboration

- **사라**: Fan Insight 결과를 전달받는다.
- **아론**: Lead Convert 이후 Account/Contact로 인수인계한다.

## [P2] TBD / Decision Needed

A/B/E/H/I는 모두 확정됐다(`05_DECISIONS.md` Decision 017·018). 남은 것은 구현
세부사항뿐이다.

- Lead Status의 정확한 Picklist Label(Candidate 단계 표현 방식)
- Agentforce AI Matching/Segment Match/Recommendation Reason의 상세 기술 구성
  (프롬프트, 참조 데이터, 평가 방식 — Decision 017 TBD와 동일)
- `Lead_Score__c`의 정확한 값 범위/계산 방식

> 위 항목은 여전히 임의로 확정하지 않는다 — "Lead로 간다"·"Agentforce를 쓴다"는
> 방향은 확정됐지만, "정확히 어떻게"는 구축하면서 채워간다.

---

## [P1] Previous Role & Contribution

> Phase 1(B2C Fan 360 MVP)에서 혜준이 실제로 수행한 역할과 기여를 보존한 History다.

# Mission

> **"Demo 당일, 화면이 예상대로 정확하게 동작한다는 것을 보장한다."**

혜준은 Cloud Alpacas의 Salesforce Experience Lead / QA Lead다. **Salesforce를
직원들이 편하게 사용할 수 있도록 만드는 사람** — 자동차에 비유하면 운전하기 편하도록
내부를 완성하고 품질을 확인하는 역할이다(02_TEAM_GUIDE.md §1-1). 승우가 만든 데이터
구조 위에 화면(Lightning Page/App), 권한, Navigation을 완성해 김매니저 같은 실제
직원이 쓸 수 있는 시스템으로 만들고, 설계대로 정확하게 동작하는지 검증한다. Salesforce
Admin 자격증을 보유하고 있어 Platform(화면·권한) 영역뿐 아니라 운영(Admin: QA·UAT·
배포) 영역도 함께 담당한다.

---

# Quick Start

1. `CLAUDE.md` §5 — MVP 범위를 정확히 알아야 "무엇을 테스트해야 하는지" 판단할 수
   있다.
2. `03_SYSTEM.md` — 검증 대상이 되는 Object/Field/Flow의 설계 원본.
3. `04_DEMO.md` — Demo Scene마다 어떤 데이터·화면이 정확해야 하는지 확인한다.
4. `02_TEAM_GUIDE.md` §6 — GitHub Projects에서 QA 이슈를 어떻게 다루는지 확인한다.

---

# Role

Salesforce Experience Lead / QA Lead. Customer 360을 직원이 쓰기 좋은 화면·권한
구조로 완성하고, 설계대로 동작하는지 검증한다.

---

# Responsibility

- Fan 360 Dashboard 등 4개 화면의 Lightning Page/App 구현, Navigation, Dynamic Page 구성
- Permission Set, Sharing 설정 — 누가 어떤 데이터를 볼 수 있는지 관리
- Report/Dashboard 구성 — Campaign Performance 등 집계 화면
- Sandbox 환경 준비 및 관리, Phase 1→2 브랜치 전략에 맞춘 배포 지원
  (`02_TEAM_GUIDE.md` §4)
- `03_SYSTEM.md`에 정의된 Object/Field/Flow가 설계대로 동작하는지 QA·UAT
- 분석성 Object(`Attendance_Record__c`, `Fan_Activity_Pattern__c`)의 데이터 정합성
  확인 — 예: 관람 횟수가 실제 Admission 건수와 맞는지
- Demo 리허설에서 발생하는 오류 발견 및 재현 시나리오 정리

---

# Deliverables

- Fan 360 Dashboard 등 4개 화면의 Lightning Page/App 구현
- QA 이슈 목록(GitHub Projects에서 관리, Label로 구분)
- Demo 백업 환경(녹화 영상 재생 포함) 점검 결과

---

# Owned Objects

Object를 직접 구축하지는 않지만(승우 담당), 아래 Object의 **데이터 정합성 검증**을
책임진다.

- `Attendance_Record__c`, `Fan_Activity_Pattern__c` — 집계 값이 원본 데이터
  (Admission, Order)와 일치하는지 확인

---

# Owned Flows

해당 없음 — Flow 구축은 승우 담당이다. 다만 Flow 실행 결과(Recommendation, Notification
Log, Slack 알림)가 트리거 조건과 맞게 생성되는지 검증한다.

---

# Owned Screens

Fan 360 Dashboard, Fan Profile, Fan Timeline, Recommendation Panel — **구현 + QA**
담당 (UX 설계는 Sara, 화면이 쓰는 Object/Field 데이터 연동은 승우와 협업)

---

# Weekly Guide

### Week 1 — Foundation

- **이번 주 목표**: Sandbox 환경을 준비한다.
- **왜 이 작업을 하는가**: 승우가 Object를 구축하기 시작하기 전에 안전하게 테스트할
  수 있는 환경이 있어야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 팀이 함께 쓸 수 있는 Sandbox.
- **누구와 협업해야 하는가**: 승우.
- **먼저 읽어야 하는 문서**: `02_TEAM_GUIDE.md` §4(브랜치 전략).
- **추천 구현 순서**: Sandbox 생성 → 접근 권한 설정 → 팀에 공유.

### Week 2 — MVP Completion

- **이번 주 목표**: 4개 화면(Lightning Page)을 구현하고, 구축된 Object/Flow/화면을
  실제 시나리오로 검증한다(목표: 2026-08-14).
- **왜 이 작업을 하는가**: Demo 당일 오류가 나오면 안 된다 — 미리 발견해야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 4개 화면 구현 완료, `04_DEMO.md`의
  8개 Scene을 한 번씩 직접 재현해본 QA 결과.
- **누구와 협업해야 하는가**: 승우(화면이 쓰는 데이터 연동, 이슈 수정), 아론(Sample
  Data 요구사항 확인).
- **먼저 읽어야 하는 문서**: `04_DEMO.md` §3, §5(Sample Data 요구사항).
- **추천 구현 순서**: 화면 구현 → Scene 순서대로 재현 → 이슈 기록(GitHub Projects) →
  승우에게 전달.

### Week 3 — Future Scope

- **이번 주 목표**: 확장 시나리오가 기존 Org에 영향을 주지 않는지 검토한다.
- **왜 이 작업을 하는가**: 새 Object 추가가 기존 Flow/화면을 깨뜨리지 않아야 한다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 확장 시 리스크 검토 의견.
- **누구와 협업해야 하는가**: 승우.
- **먼저 읽어야 하는 문서**: `05_DECISIONS.md` Decision 005.
- **추천 구현 순서**: 확장 설계 검토 → 리스크 포인트 정리.

### Week 4 — Polish

- **이번 주 목표**: 발견된 QA 이슈를 모두 해결하고 Dashboard/UI를 최종 점검한다.
- **왜 이 작업을 하는가**: 발표 직전 마지막 안정화 주간이다.
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 열린 QA 이슈가 없는 상태.
- **누구와 협업해야 하는가**: 승우, Sara(UI 조정 요청).
- **먼저 읽어야 하는 문서**: 없음(QA 이슈 기반).
- **추천 구현 순서**: 이슈 재검증 → 회귀 테스트(이전에 고친 부분이 다시 깨지지
  않았는지).

### Week 5 — Presentation

- **이번 주 목표**: Demo 백업 환경(녹화 영상 포함)을 최종 점검한다.
- **왜 이 작업을 하는가**: 네트워크·환경 문제에 대비해야 한다(04_DEMO.md §1).
- **이번 주가 끝났을 때 완성되어 있어야 하는 것**: 라이브가 실패해도 즉시 녹화
  영상으로 전환 가능한 상태.
- **누구와 협업해야 하는가**: 은영(영상 소재), 아론(리허설).
- **먼저 읽어야 하는 문서**: `04_DEMO.md` §1.
- **추천 구현 순서**: 리허설 참여 → 백업 전환 테스트 → 최종 점검 체크리스트 확인.

---

# Related Documents

- `03_SYSTEM.md` — 검증 대상 설계 원본.
- `04_DEMO.md` §3, §5 — Scene별 검증 기준과 필요 데이터.
- `02_TEAM_GUIDE.md` §6 — GitHub Projects 이슈 관리 방식.

---

# GitHub Projects

Task와 진행 상황은 GitHub Projects에서 관리한다.

---

# Learning Path

1. Business 이해: `00_STORY.md`의 Pain Point를 알아야 "무엇이 해결됐는지" 검증
   기준을 세울 수 있다.
2. Customer 360 이해: `03_SYSTEM.md` §3(ERD)로 Object 간 관계를 파악해야 어떤
   데이터가 어디에 영향을 주는지 안다.
3. Salesforce 구현: Sandbox 관리와 기본 QA(Flow 디버그, 데이터 확인) 방법을
   승우와 함께 익힌다.

---

# 🤝 협업 포인트

- **승우**: 화면 구현에 필요한 Object/Field를 미리 맞추고, 발견한 QA 이슈를 구체적인
  재현 시나리오와 함께 전달한다.
- **Sara**: 화면 UX 설계를 넘겨받아 구현하고, 실제 사용성 피드백을 준다.
- **은영**: Fan App이 만든 데이터가 시간 순서 등에서 자연스러운지 확인한다.
- **아론**: Demo Scene 순서와 필요한 Sample Data를 미리 공유받는다.
