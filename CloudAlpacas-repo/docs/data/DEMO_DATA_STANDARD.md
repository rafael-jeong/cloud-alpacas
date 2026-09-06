# DEMO_DATA_STANDARD.md — 공용 Dummy Data 제작 규칙 (Data Contract)

> 이 문서는 **실제 데이터 파일이 아니다.** `SAMPLE_DATA.md`/`SAMPLE_DATA_v2_1.md`/
> `DEMO_DATASETS.md`처럼 실제 레코드 값을 담지 않는다. 대신 팀원 모두가 같은 규칙으로
> Dummy Data를 만들 수 있도록 하는 **공용 기준**만 정의한다(CLAUDE.md §7 중복 방지).
> `04_DEMO.md §11`에서 이 문서를 참조한다.

---

## 6.1 목적

모든 팀원이 동일한 규칙으로 Demo Data를 만들고, 각자 만든 Fan/Order/Product/
Game/Partner 데이터가 이름과 구조가 달라 끊기지 않고 **하나의 End-to-End
Scenario로 연결되도록** 하는 것이 이 문서의 유일한 목적이다. 복잡한 데이터
거버넌스 문서가 아니라: **"누가 무엇을 만들고, 어떤 Record와 연결되며, 어떤
규칙을 지켜야 우리 Demo가 하나의 Story로 이어지는가"**에만 답한다.

---

## 6.2 공용 Record Naming Rule

기존 프로젝트에 이미 쓰이고 있는 이름 규칙을 그대로 따른다(`SAMPLE_DATA_v2_1.md`,
`DEMO_DATASETS.md` 기준) — 새로 정하지 않는다.

| Entity | 규칙 | 기존 예시 |
|---|---|---|
| Fan(Person Account) | 한글 성명 | 이루키, 박서연, 김도현, 최민재, 정하윤 |
| Player(Contact) | 한글 성명 | 문태양, 강도윤, 이서준, 박현우 |
| Product2 | `카테고리 - 상세` 또는 `선수명 상품명(비고)` | "티켓 - 외야석", "멤버십 - Standard", "문태양 유니폼(홈)" |
| Season__c | `YYYY 시즌` | 2025 시즌, 2026 시즌 |
| Campaign | 영문 Title Case + Campaign | Welcome Campaign, Membership Campaign |
| Case Subject | 한글 자연어 | "티켓 환불 문의" |

**[P2] Phase 2 신규 Entity** — 아직 확립된 규칙이 없어 아래를 제안한다(팀 확인 필요, TBD):

| Entity | 제안 규칙 | 근거 |
|---|---|---|
| Account(Sponsor/Partner) | 회사/브랜드명 | 대표 시나리오는 d'Alba(달바) — 초기 Wireframe 예시는 "Sanrio", "스위트클라우드" 등이었으나 2026-08-18 멘토링으로 대표 시나리오가 교체됐다(`05_DECISIONS.md` Decision 019) |
| Lead | Company 필드에 후보 기업명 | Wireframe 그대로 |
| Opportunity | `{Account명} × Cloud Alpacas — {Sponsorship명}` | 예시: "d'Alba × Cloud Alpacas — Advertising Sponsorship" |

> ⚠️ **팀 확인 필요**: 초기 Wireframe에는 실제 존재하는 기업명(Sanrio 등)이 예시로
> 쓰였고, 지금은 d'Alba를 대표 시나리오로 쓴다. Demo에서 실제 브랜드명을 그대로 쓸지, 가상 브랜드명으로 바꿀지는
> 이 문서가 아니라 팀이 별도로 결정한다.

---

## 6.3 Shared Scenario ID

Fan → Fan Insight → Partner Candidate → Lead → Account → Contact → Opportunity →
Product → Quote → Campaign → Performance가 하나의 이야기로 연결되도록, 관련
레코드의 **Description/Name에 공통 Scenario ID를 표기**하는 것을 제안한다.

- 형식: `SCN-B2B-001` (B2B는 `SCN-B2B-`, B2C는 필요 시 `SCN-B2C-`)
- 예: Lead의 Description에 `[SCN-B2B-001]`을 포함, 이후 전환되는 Account/
  Opportunity/Campaign의 Description에도 동일하게 포함

> 이건 **새 Salesforce Field가 아니라 Naming/Description 관례**다 — Object/Field를
> 새로 만드는 것은 Technical Decision(`03_SYSTEM.md §7`)의 영역이라 이 문서에서
> 확정하지 않는다.

---

## 6.4 Fan Data Distribution

### 6.4.1 최종 Demo 목표 규모 — 최소 5,000 Fans

**최종 Demo 목표는 Fan 최소 5,000명 규모다.** (2026-08-18 멘토링으로 기존 "약
1,000명" 목표에서 상향 — `05_DECISIONS.md` Decision 019. 100명 이하 소규모
데이터로는 Fan Segment/기업 Matching/Scoring의 분포를 설득력 있게 보여주기
어렵다는 멘토 피드백을 반영했다.)

✅ **Org 확인 결과 (읽기 전용 조회)**: `CloudAlpacasProd`에 `RecordType.DeveloperName
= 'Fan'` 기준 **Account 5,024건**이 존재한다 — 목표 규모(최소 5,000명) 충족을
**헤드카운트 기준으로 확인**했다. 단, 이 5,024건이 §6.4.2의 분포 기준(Current
Segment/Fan Value/Gender/연령대/대표 팬층 비중 등)과 `Gender__c`/`Birthdate` 등
필수 Field를 실제로 만족하는지는 **별도 QA 대상이며 아직 검증하지 않았다** —
"인원수가 찼다"와 "분포/Field가 Demo 목적에 맞게 채워졌다"는 다른 질문이다.

| 단계 | 규모 | 목적 | 상태 |
|---|---|---|---|
| 소규모 QA 데이터 | 현재 30~35명(`P2_DUMMY_DATA_MASTER.md`) | 구조/화면/Flow 검증용 — **삭제하지 않고 그대로 유지** | ✅ 존재함 |
| 최종 Target Demo Scale | **최소 5,000 Fans** | 실제 발표 규모 — Fan Segment/기업 Matching/Scoring 분포의 설득력 확보 | ✅ **헤드카운트 충족(Org 5,024명 확인)** — 🔵 Field/Distribution QA는 별도 대상, 아직 미검증 |

> 기존에 "30~50명 권장"이라고 안내했던 §10(`04_DEMO.md`) 규모 제안은 **소규모
> QA 단계의 기준**으로 재해석한다 — 최종 목표는 5,000명이며, 30~50명은 그 전에
> 화면·Flow가 깨지지 않는지 검증하는 최소 단계다.

### 6.4.2 5,000명 데이터가 따라야 할 분포 기준 (Field/Distribution QA 체크리스트)

아래는 5,000명 데이터가 만족해야 하는 **분포 비율**이다 — 현재 소규모 데이터
(§1 대표팬 11명 포함 30명)에서 확인한 비율을 그대로 스케일업한다
(`P2_DUMMY_DATA_MASTER.md` §1~2 참고). 절대 인원수는 "최소 5,000명" 기준 예시이며,
실제 총원(Org 확인 5,024명, §6.4.1)에 맞춰 비율을 그대로 적용한다.

> ⚠️ Org에 5,024건이 이미 존재하는 것(§6.4.1)과, 그 5,024건이 아래 분포 기준·
> 필수 Field(`Gender__c`/`Birthdate` 등)를 실제로 만족하는지는 **별개의 질문**이다.
> 이 표는 앞으로 **QA 대상**으로 남는다 — 아직 검증되지 않았다.

| 축 | 기존 확정 값 목록 | 분포 기준(5,000명 스케일 예시) |
|---|---|---|
| Current Segment(Life Cycle) | New/Active/At-Risk/Dormant/Churned/Unreachable(6종, Decision 009) | 각 값 최소 5% 이상 등장(6종 균등이면 약 833명씩) |
| Fan Value Tier | 일반/우수/VIP(Decision 009·010) | VIP는 소수(전체의 10~15% 수준, 약 500~750명) |
| Engagement Level | 가입/관심/활동/충성/멤버십/핵심 팬(6종, Decision 010) | 각 값 최소 5% 이상(약 250명 이상) |
| **[P2] Gender__c** | 남/여(`03_SYSTEM.md §2.1`) | 균형 있게 분배(예: 5:5 또는 4:6) — 정확한 비율은 TBD |
| **[P2] 연령대**(Birthdate 기반) | 표준 필드 | 10대~50대 이상 고르게, 특정 구간(예: 20~30대)에 의도적으로 더 몰아 "대표 세그먼트"를 만든다 |
| **[P2] SCN-B2B-001 대표 팬층(10~30대 여성, 뷰티/라이프스타일 관심)** | `P2_DUMMY_DATA_MASTER.md` §2.1 | 5,000명 규모에서도 이 팬층의 비중 변화(약 18%→35% 이상)가 **통계적으로 뚜렷하게** 드러나도록 최소 수백 명 단위로 스케일업 — 정확한 인원수는 TBD |

Naming/Cross-Object Consistency 규칙(§6.2·§6.5)은 5,000명 규모에서도 동일하게
적용한다 — 규모가 커진다고 규칙이 달라지지 않는다.

> 이 표는 "각 값이 최소 1번은 등장해야 한다"던 기존 QA 원칙(`SAMPLE_DATA_v2_1.md`)을
> 유지하되, Phase 2에서는 **"그룹"이라고 부를 수 있는 규모, 나아가 "통계적으로
> 유의미한 규모"**까지 확장하는 것이 다른 점이다.

---

## 6.5 Cross-Object Consistency

각자 담당한 Object만 채우지 않고, 관련 Record까지 논리적으로 맞아야 한다 — 기존
문서(`03_SYSTEM.md`, `SAMPLE_DATA_v2_1.md`)에 이미 있는 관계를 체크리스트로
정리한 것이며 새 규칙을 만들지 않는다.

- Fan이 Order를 가지면 → 그 Product2/PricebookEntry가 먼저 존재해야 한다.
- Order에 `Game__c`가 연결되면(Ticket Purchase) → 그 `Game__c`의 `Season__c`가
  먼저 존재해야 하고, 관람률 계산에 넣으려면 `Status__c = Played`여야 한다.
- `Admission__c`를 만들려면 → 그 Fan의 `Attendance_Record__c`가 먼저 있어야
  한다(Master-Detail, Decision 012).
- `Fan_Activity_Pattern__c.Total_Spend__c`는 → 그 Fan+Season의 실제 Order
  합계(Refunded/Cancelled 제외)와 일치해야 한다(Decision 013).
- `Current_Segment__c`(Person Account, 캐시)는 → `Fan_Segment_History__c`의
  최신 행과 일치해야 한다(Decision 009).
- **[P2]** Lead가 Account/Contact/Opportunity로 전환되면 → 원래 Lead의 Company/
  Industry/Target Segment 정보가 전환된 레코드에도 논리적으로 이어져야 한다.

---

## 6.6 Demo Data Owner

`02_TEAM_GUIDE.md §2`(Object/Flow/Screen 담당)를 우선 참조한다 — 이 표는 그
배정을 Data 영역 기준으로만 다시 정리한 것이다.

| Data Domain | Owner | Creates | Depends On | QA |
|---|---|---|---|---|
| B2C Fan Core(Person Account, `Gender__c`/`Birthdate` 포함) | 아론 | Fan 레코드 | Contact(Player) | 혜준 |
| B2C Transaction(Order/OrderItem/Admission 등) | 아론 | 기존 패턴 그대로 | Product2/Season__c/Game__c | 혜준 |
| B2C Analytics(Fan_Activity_Pattern/Engagement_Signal 등) | 아론 | 기존 패턴 | Order/Admission | 혜준 |
| **[P2] Fan Insight/Fan Grouping** | 사라 | Fan Insight Report, Target Segment/Segment Match 관련 데이터 | B2C Fan Core | 혜준 |
| **[P2] Lead(Candidate 단계 포함)** | 혜준 | Lead 레코드 | 사라의 Fan Insight | 아론 |
| **[P2] Account/Contact(Partner)** | 아론 | Account/Contact(Lead Convert 결과) | 혜준의 Lead | 은영 |
| **[P2] Opportunity** | 은영 | Opportunity 레코드 | 아론의 Account/Contact | 승우 |
| **[P2] Product/Quote/Campaign** | 승우 | Sponsorship Package, Quote, Campaign(Collaboration Record Type) | 은영의 Opportunity | 사라 |

> ✅ B2B 데이터 영역 담당자는 `02_TEAM_GUIDE.md` §11(Phase 2 Team Roles)에
> 확정되어 있다 — 위 표는 그 배정을 Data 영역 기준으로만 다시 정리한 것이며
> 새로 배정하지 않는다. 실제 Record 단위 Owner/Related Record는
> `docs/decision_sheet/P2_DATA_CONTRACT.md`를 따른다(중복 방지).

---

## 6.7 Data Freeze

Demo 직전에 공용 Dummy Data가 임의로 바뀌면 다른 팀원의 화면/Flow가 깨질 수 있다.

```
Draft → QA → Data Freeze → Demo
```

- **Draft**: 각자 담당 영역의 Dummy Data를 이 문서 기준으로 작성
- **QA**: 혜준이 Cross-Object Consistency(§6.5) 기준으로 검증
- **Data Freeze**: Freeze 이후에는 공용 데이터를 임의로 변경하지 않는다 — 변경이
  필요하면 팀 채널에 먼저 공유하고 합의 후 반영한다
- **Demo**: Freeze된 데이터 그대로 리허설·발표에 사용
