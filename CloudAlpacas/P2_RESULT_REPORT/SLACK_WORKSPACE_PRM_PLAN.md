# Slack PRM 업무 허브 — 기획안 (승인 대기, 작업 미착수)

> ⚠️ 이 문서는 **기획안**입니다. 사용자 승인 전까지 채널 생성·자동화 등 실제 작업은 진행하지 않습니다.
> ⚠️ `SLACK_MCP_HANDOFF_CONTEXT.md`와 동일한 원칙 — **로컬 전용, git에 커밋하지 않음**.
> 작성일: 2026-08-26 / 대상: "이 매니저(B2B PRM 담당자, 가칭)" 워크플로우 / 작성자: 승우 요청, Claude 작성

---

## 1. 이 기획안의 목적

`SLACK_MCP_HANDOFF_CONTEXT.md`에서 Slack MCP 연동(claude.ai 호스팅 커넥터)이 검증 완료됐습니다. 이제 "이 매니저" 페르소나(`00_STORY.md` §4, §8, §9)의 실제 B2B Sponsorship Sales 워크플로우에 맞춰 Slack 워크스페이스를 어떻게 구성할지 구체적으로 설계합니다.

**전제 확인**: 이 워크스페이스는 팀의 기존 개발 커뮤니케이션 채널(`02_TEAM_GUIDE.md` §7 — "채널을 나누지 않고 하나의 Slack 채널" 원칙, 팀 규모가 커질 때까지 유지)을 대체하거나 건드리지 않습니다. 이건 **별개의 업무 도구**입니다 — 팀 개발 소통이 아니라, B2B PRM(스폰서십 영업) 업무를 위한 별도 운영 화면입니다.

**역할 분담 재확인** (`SLACK_MCP_HANDOFF_CONTEXT.md` §2):
- 기존 Salesforce Slack 봇: Salesforce 데이터 조회·분석·CRUD
- Claude(MCP): 채널 구조 설계, 메시지 분석, 업무 정리, 문서 생성, 반복 업무 자동화
- 이 둘이 겹치지 않게, 아래 설계 전체에서 "누가 게시하는가"를 명시합니다.

---

## 2. 이 매니저의 워크플로우 요약 (설계의 근거)

`00_STORY.md` §8.3·§9, `01_PROJECT.md` §2.7 기준. Slack 채널 구조는 이 흐름을 그대로 반영합니다.

```
Fan 360 Data 분석 → 팬덤 광고 가치 발견 → 기업 DB(DART Open API, ~100개)
→ Agentforce Matching → Top 10 추천 + Recommendation Reason
→ (담당자가 선택) → Lead 등록 → Lead Qualification / Lead Score
→ Account/Contact 전환 → Opportunity 생성
→ Sponsorship Package(Product2)/Quote 제안 → Negotiation
→ Closed Won → Contract/Sponsorship Revenue → Pipeline/Revenue Dashboard
```

핵심 구분(설계에서 계속 등장):
- **Agentforce Fit/Recommendation Score**(Segment Match) ≠ **`Lead_Score__c`** — 전자는 "팬덤과 기업이 잘 맞는가"(Lead 되기 전), 후자는 "실제 계약 가능성"(Lead가 된 후, 담당자 판단). 두 값은 다른 채널/다른 시점 정보로 다뤄야 합니다.
- Agentforce의 Top 10 추천은 Salesforce Object가 아닙니다(Decision 020) — Lead가 되는 건 담당자가 실제로 선택한 기업뿐입니다.

---

## 3. 채널 구조 (4개, 기존 초안 정교화)

`SLACK_MCP_HANDOFF_CONTEXT.md` §5 초안을 워크플로우 단계에 정확히 맞춰 재정리했습니다.

### 3.1 `#prm-research` — Fan Insight · 기업 발굴 (Pre-Lead 단계)

워크플로우 1~3단계(Fan 360 분석 → 기업 DB Matching → Top 10 추천)를 다룹니다. **아직 Lead가 아닌** 단계 전용 — Lead가 되면 `#prm-deals`로 넘어갑니다.

- Fan 360 Insight 분석 결과(팬덤 관심사 가설 — 뷰티/라이프스타일/F&B 등)
- Agentforce Top 10 추천 + Recommendation Reason 요약
- Outbound 대상 선정 논의(아직 Lead 등록 전 검토)

### 3.2 `#prm-command-center` — 오늘의 업무 허브

- 오늘 할 일, 긴급 처리 건
- 계약(Contract) 만료 임박 알림
- Quote/제안서 검토 요청
- 미팅 일정, Follow-up 리마인더
- Lead Status 변경(신규 등록/접촉 시작/Qualified) 알림

### 3.3 `#prm-deals` — 개별 Opportunity 스레드

Lead가 Qualified되어 Account/Contact/Opportunity로 전환된 이후 전 과정.

- Opportunity별 스레드(예: "d'Alba × Cloud Alpacas — Advertising Sponsorship")
- Quote 초안·버전 이력
- Negotiation 경과, 의사결정 로그
- Expected Benefit(단기/중기/장기), Target Segment
- Salesforce 레코드 링크

### 3.4 `#prm-pipeline` — 파이프라인/매출 현황

- Stage별 분포(Opportunity Kanban 요약), Weighted Pipeline
- Monthly Revenue Target 대비 Closed Won, Revenue Gap
- 30/60일 이내 계약 만료 목록
- Follow-up 지연 건
- Salesforce Dashboard 링크(Decision 018-J 방향 — Report/Dashboard 기반)

---

## 4. Canvas 활용 계획

이번 스모크 테스트로 **Canvas 생성·조회가 실제로 동작함을 확인**했습니다(`SLACK_MCP_HANDOFF_CONTEXT.md` §4-1-4). 채널마다 아래처럼 활용을 제안합니다.

| 채널 | Canvas 용도 | 갱신 주체·주기 |
|---|---|---|
| `#prm-command-center` | "오늘의 체크리스트" | Claude, 매일(Phase 3에서 Cron 자동화) |
| `#prm-pipeline` | "Pipeline Snapshot"(표+차트 — Canvas가 `data_visualization` 차트 지원 확인됨) | Claude, 주간 |
| `#prm-deals` | Opportunity별 요약 Canvas(Quote 이력, Segment Match/Recommendation Reason, Expected Benefit 3단) | Claude, Opportunity 생성/Stage 변경 시 |
| `#prm-research` | "이번 주 Top 10 추천" | Claude, Agentforce 실행 주기에 맞춰 |

---

## 5. 자동화 매핑 — 무엇을, 어디에, 누가, 언제부터

| Salesforce 이벤트/단계 | 게시 채널 | 담당 주체 | 도입 Phase |
|---|---|---|---|
| Agentforce Top 10 추천 생성 | `#prm-research` | Claude(요약+Canvas) | Phase 2 |
| Lead 신규 등록 | `#prm-research` → `#prm-command-center` | 기존 봇(원자료) | Phase 1(조회)/3(자동 알림) |
| Lead Status 변경(Qualified 등) | `#prm-command-center` | 기존 봇 | Phase 3 |
| Opportunity 생성 | `#prm-deals`(신규 스레드+Canvas) | Claude(반자동 초안 → 승우 검토) | Phase 2 |
| Quote 생성/버전업 | `#prm-deals` | Claude(초안) + 승우 검토 | Phase 2 |
| Opportunity Stage 변경 | `#prm-deals` 스레드, `#prm-pipeline` 집계 | 기존 봇(원자료) + Claude(주간 요약) | Phase 3 |
| Closed Won → Contract | `#prm-pipeline`, `#prm-command-center` | 기존 봇 | Phase 3 |
| 계약 만료 30/60일 전 | `#prm-command-center` | Claude(Cron) | Phase 3 |
| 주간/월간 Pipeline 스냅샷 | `#prm-pipeline` Canvas | Claude(Cron) | Phase 3 |

**원칙**: Salesforce 원자료 조회·CRUD는 기존 봇이 하던 대로 두고, Claude는 "여러 정보를 모아 정리·초안화·주기적 요약"하는 역할만 맡습니다 — 중복 구현하지 않습니다.

---

## 6. 단계별 도입 순서 (기존 합의 재확인, `SLACK_MCP_HANDOFF_CONTEXT.md` §6)

1. **읽기 전용부터 검증** — 채널 검색, 스레드 요약. 승인/위험 없이 바로 가치 검증.
2. **게시는 반자동으로 시작** — Claude가 초안 생성 → 승우 검토 → 게시. 완전 자동 게시는 신뢰 쌓인 뒤로 미룸.
3. **스케줄 자동화** — CronCreate로 "매일 정해진 시간에 초안 생성"부터 시작(이번 세션에서 CronCreate 기능 존재 확인됨).
4. **채널 생성·북마크·Canvas 관리 자동화** — 이미 Canvas·채널 생성 자체는 검증 완료(§4-1-4). 이 단계에서는 "언제 자동으로 새 스레드/Canvas를 만들지"의 트리거 로직을 다룸.
5. **Slash Command·메시지 트리거 자동화는 마지막** — 별도 Events API 수신 서버가 필요해 투자 규모가 다름. `@봇 자연어` 방식이 실제로 자주 쓰인다고 검증된 뒤 착수.

---

## 7. 아직 확정 안 된 것 (TBD — 임의로 값을 정하지 않음)

`03_SYSTEM.md` §7 기준, 아래 항목들은 Salesforce 쪽에서 아직 확정되지 않아 이 기획안도 정확한 필드명/값을 못 박지 않습니다. 확정되는 대로 자동화 문구를 맞춰 조정합니다.

- Lead Status의 정확한 Picklist Label(Candidate/Contacted/Qualified 등 — Decision 018-A)
- `Lead_Score__c`의 정확한 Type/값 범위(Decision 018-E)
- Target Segment Picklist 값 목록(Decision 018-G)
- Pipeline/Revenue Dashboard의 정확한 지표·계산식(§7.1)
- Account의 `Active Sponsorship`/`Total Sponsorship Value` 필드 — **보류(On Hold)**, Decision 018-K

---

## 8. 실행 전에 확인하고 싶은 것

작업 시작 전, 아래만 확인해주시면 됩니다.

1. 채널 이름 4개(`#prm-command-center`, `#prm-pipeline`, `#prm-deals`, `#prm-research`) 그대로 진행할지, 바꿀 이름이 있는지
2. 이 워크스페이스를 실제 운영할 사람이 승우님 1인인지, 다른 팀원(은영 등 Opportunity 담당)도 채널에 초대해야 하는지
3. 1번(읽기 전용 검증)부터 바로 시작해도 되는지, 아니면 이 기획안 자체를 먼저 팀과 공유·검토할 시간이 필요한지
4. 스모크 테스트로 만든 프라이빗 채널 `mcp-smoke-test`를 그대로 재활용할지(예: `#prm-command-center`로 이름 변경), 아니면 새로 만들고 그건 정리할지

승인해주시면 그때 Phase 1(읽기 전용)부터 시작하겠습니다.
