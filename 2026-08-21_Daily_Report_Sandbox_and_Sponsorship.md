# 2026-08-21 작업 보고 — Sandbox 연결 & d'Alba 단기/장기 스폰서십 구성

> 작성자: 승우(Rafael) · 기준일: 2026-08-21

---

## 1. Sandbox(`prmaidev`) 연결 작업

- **SFDX CLI 연결 완료**
  - `sf org login web --instance-url https://test.salesforce.com --alias prmaidev`로 인증 성공
  - Org Id `00DhG000000kwDtUAI`, Username `wjdtmddn5390@gmail.com.alpaca.prmaidev`
  - 트러블슈팅: 이전 실패한 로그인 시도의 좀비 프로세스가 OAuth 콜백 포트(1717)를 점유해 `PortInUseError` 발생 → 프로세스 종료 후 재시도로 해결
- **CA SF 커넥터(claude.ai) 연결은 미완료**
  - Sandbox 로그인 시도 시 `error=invalid_client_id&error_description=client%20identifier%20invalid` 발생
  - 원인: claude.ai 커넥터가 쓰는 Connected App/External Client App이 이 Sandbox에 등록되어 있지 않음 (Sandbox 생성 이후 프로덕션에 추가된 App으로 추정)
  - 해결 방법 후보: Sandbox 새로고침(무거운 작업, 팀 협의 필요) — 아직 미결정
  - **당분간 Sandbox 작업은 SFDX CLI로만 진행** (메타데이터 배포·데이터 조회 모두 커버 가능, 검증 완료)

---

## 2. 프로덕션 Org — d'Alba 단기/장기 스폰서십 시나리오 구성

배경: "단기 스폰서십을 먼저 진행해보고 장기 스폰서십 체결 여부를 결정한다"는 시나리오에 맞춰, 이미 생성되어 있던 두 Opportunity에 Product·Quote·Campaign을 연결.

### 2.1 d'Alba Short-Term Sponsorship (1년 트라이얼)

- 기존 Opportunity(Owner: Eunyeong Doh) 대상, 금액 변경 이력: 5천만 → **3억 원**
- **Product**: 신규 생성 없이 기존 카탈로그의 `전광판 광고 + Brand Day 패키지`(3억 원) 재사용 — 단일 상품
- **Quote**: `d'Alba Short-Term Sponsorship Quote`, Draft, Opportunity와 Syncing 연결, Grand Total 3억 원으로 금액 일치
- **Campaign**: 신규 생성 `d'Alba Short-Term Sponsorship Campaign` (Record Type: Sponsorship Collaboration, Status: Planned), Opportunity의 Primary Campaign Source로 연결
- **Campaign Member**: Fan Person Account `천서율` 추가 (Status: Sent)
- 사용자 확인: 단일 상품 구성 그대로 유지하기로 결정 (다각화 안 함)

### 2.2 d'Alba Long-Term Sponsorship (5년 계약)

- 기존 Opportunity(Owner: Hyejune Jo) 대상, 금액 변경 이력: 3억 → **30억 원**
- **1차 구성(폐기)**: 기존 단일 상품(전광판 광고 + Brand Day 패키지) × 수량 10 = 10년 계약, 30억 원
- **최종 구성**: 사용자 피드백에 따라 10년 → **5년**으로 단축, 상품도 5종으로 다각화

  | Product | 연간 단가 | 수량(년) | 5년 총액 |
  |---|---:|---:|---:|
  | 전광판 광고 + Brand Day 패키지 | 3억 | 5 | 15억 |
  | 헬멧 로고 광고 | 1억 | 5 | 5억 |
  | 구장 내 특별 구역 명명권 | 8천만 | 5 | 4억 |
  | 외야 펜스 광고 | 8천만 | 5 | 4억 |
  | 경품 증정 프로모션 데이 | 4천만 | 5 | 2억 |
  | **합계** | **6억/년** | **5년** | **30억** |

- **Quote**: 기존 `d'Alba Sponsorship Quote` 재사용, Grand Total 30억 원으로 Opportunity Amount와 일치
- **Campaign**: 기존 `d'Alba Sponsorship Campaign`을 Primary Campaign Source로 재연결

### 2.3 트러블슈팅 — Quote Sync 중복 생성 이슈

- Quote가 이미 `IsSyncing = true`인 상태에서 Opportunity Line Item과 Quote Line Item을 **동시에 직접 추가**하면, Salesforce의 Quote Sync 엔진이 반대편에 자동으로 짝을 하나 더 생성해서 **금액이 의도치 않게 2배**가 되는 현상을 확인
- 대응: 중복 생성된 Line Item 쌍을 식별해 삭제, 이후로는 **Syncing 중인 Quote에는 한쪽(Quote Line Item)만 추가**해서 Opportunity 쪽이 자동 미러링되도록 처리 방식을 변경
- 참고: Opportunity Line Item을 삭제하면 연결된 Quote Line Item도 함께 삭제됨(양방향 Sync 확인)

---

## 3. 남은 이슈 / 다음 확인 사항

- CA SF 커넥터의 Sandbox 연결 방법 확정 필요 (새로고침 여부 팀 협의)
- Short-Term Opportunity의 Quotes 관련 목록이 화면에 안 뜨는 이슈 리포트됨 — API로는 데이터 정합성 확인 완료(OpportunityId 정확히 연결, 삭제 안 됨), 화면 미표시 원인은 미확정 상태로 계속 확인 중
- P2 Campaign Performance Dashboard 관련 잔여 이슈는 [`P2_CAMPAIGN_PERFORMANCE_IMPLEMENTATION_STATUS.md`](./P2_CAMPAIGN_PERFORMANCE_IMPLEMENTATION_STATUS.md) 참고
- PRM Growth Agent(AI WOW Point) 설계는 [`P2_PRM_AI_AGENT_WOW_POINT_DESIGN.md`](./P2_PRM_AI_AGENT_WOW_POINT_DESIGN.md) 참고 — Sandbox 연결 완료 후 Phase 1 구현 착수 예정

---

## 4. GitHub 반영 제안

권장 경로:

```text
docs/prm/2026-08-21_Daily_Report_Sandbox_and_Sponsorship.md
```

권장 Commit Message:

```text
docs: log sandbox connection and d'Alba short/long-term sponsorship setup
```
