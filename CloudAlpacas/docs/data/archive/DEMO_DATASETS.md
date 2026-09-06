# DEMO_DATASETS.md — 이루키의 Demo 시나리오 데이터셋

> 이 문서는 `04_DEMO.md`의 Scene 순서를 그대로 따라가며, **이루키 한 사람의 여정을
> 실제 레코드 값으로** 채운다. 선수·상품·경기 같은 배경 데이터는 `SAMPLE_DATA_v2_1.md`를
> 참고한다(중복 방지, CLAUDE.md §7). Object/Field 정의는 `03_SYSTEM.md`를 따른다.
> (구 `SAMPLE_DATA.md`는 2026-08-17 `docs/data/archive/`로 이동됨 — 내용은
> `SAMPLE_DATA_v2_1.md`에 포함되어 있다.)
>
> 담당: 아론, 검증: 혜준. Demo 리허설 전 이 값 그대로 Org에 적재한다(승우 협업).

---

## 0. 이루키 — Fan(Person Account) 기준 레코드

| Field | 값 |
|---|---|
| Name | 이루키 |
| 나이 | 27세, 직장인 (00_STORY.md §4) |
| `Acquisition_Channel__c` | SNS |
| `Favorite_Player__c` | 문태양 (SAMPLE_DATA.md §1) |
| `Current_Segment__c` | Scene이 진행되며 New Fan → Active Fan으로 바뀐다(§2 참고) |
| `Engagement_Level__c` | 계산 로직 미확정(TBD, `03_SYSTEM.md` §5) — Demo에서는 값을 채우지 않는다 |
| `Engagement_Score__c` | 계산 공식·자동 계산 방식 모두 미확정(TBD, `03_SYSTEM.md` §5) — Demo에서는 값을 채우지 않는다. 채워야 한다면 임의 예시 값일 뿐 실제 운영 공식이 아님을 이 문서에 함께 표기한다. |
| `Fan_Value_Tier__c` | 일반 (Scene 7에서 VIP "후보"로 감지되지만, `Fan_Value_Tier__c`가 자동으로 VIP로 바뀌지는 않는다 — 김매니저 확인 후 수동 변경. `05_DECISIONS.md` Decision 009·010) |
| Email/SMS/Push Opt-In | 모두 체크(가입 시 동의) |

---

## 1. Scene 1 — SNS (Salesforce 데이터 없음)

이 Scene은 Fan App 영상만 존재한다(04_DEMO.md §3 Scene 1) — 아직 Fan 레코드가 없다.

---

## 2. Scene 2 — 회원가입

| Object | Field | 값 |
|---|---|---|
| Person Account | 생성일 | 2026-04-20 |
| `Fan_Segment_History__c` | `Segment__c` / `Changed_Date__c` / `Reason__c` | New Fan / 2026-04-20 / "최초 가입" |
| `Notification_Log__c` | `Channel__c` / `Content__c` / `Sent_Date__c` | Email / "Cloud Alpacas에 오신 것을 환영합니다, 이루키님!" / 2026-04-20 |

가입 다음 날 SNS 반응이 한 번 더 기록된다 — `Favorite_Player__c` = 문태양으로 설정된
근거다.

| Object | Field | 값 |
|---|---|---|
| `Engagement_Signal__c` | `Signal_Type__c` / `Source__c` / `Player__c` / `Signal_Date__c` | SNS Click / Instagram / 문태양 / 2026-04-21 |

---

## 3. Scene 3 — 첫 티켓 구매

| Object | Field | 값 |
|---|---|---|
| Order | `Order_Type__c` / `Purchase_Channel__c` / `Game__c` | Ticket Purchase / 온라인 / 2026-05-02 vs 레드폭스 |
| OrderItem | Product2 / `Section__c` / `Row__c` / `Seat_Number__c` | 티켓 - 외야석 / 외야 C구역 / 15열 / 15 |

---

## 4. Scene 4 — 첫 직관

| Object | Field | 값 |
|---|---|---|
| `Admission__c` | `Game__c` / `Admission_Time__c` / `Gate__c` | 2026-05-02 vs 레드폭스 / 2026-05-02 17:50 / Gate 2 |
| `Fan_Segment_History__c` | `Segment__c` / `Changed_Date__c` / `Reason__c` | Active Fan / 2026-05-02 / "첫 직관 완료" |

---

## 5. Scene 5 — 첫 굿즈 구매

| Object | Field | 값 |
|---|---|---|
| Order | `Order_Type__c` / `Purchase_Channel__c` | Goods Purchase / 온라인, 2026-05-16 (문태양 유니폼(홈), SAMPLE_DATA.md §2.4) |
| `Recommendation__c` | `Recommended_Action__c` / `Reason__c` / `Status__c` | Favorite Player Campaign / "문태양 관련 굿즈 첫 구매" / Executed |
| `Benefit__c` | `Benefit_Type__c` / `Status__c` / `Issued_Date__c` | Discount(다음 구매 10%) / Issued / 2026-05-16 |

---

## 6. Scene 6 — 재방문

2026-05-16, 2026-05-30 경기에도 추가로 티켓을 구매해 관람한다(SAMPLE_DATA.md §3의
경기 일정 사용).

| Object | Field | 값 |
|---|---|---|
| `Admission__c` (2건 추가) | `Game__c` | 2026-05-16 vs 블루웨일스, 2026-05-30 vs 스톰이글스(가상) |
| `Fan_Activity_Pattern__c` | `Period__c` / `Games_Attended__c` / `Goods_Purchases__c` / `Total_Spend__c` / `Analyzed_Date__c` | "2026 시즌 상반기" / 3 / 1 / 124,000원 / 2026-05-31 |

> `Total_Spend__c` 계산: 티켓 3건(10,000 + 15,000 + 10,000) + 굿즈 1건(89,000) =
> 124,000원.

---

## 7. Scene 7 — VIP 후보 감지

VIP 후보 조건(03_SYSTEM.md §4.5): **재방문 3회 이상 AND 총 지출 ≥ 100,000원**(Demo용
임계값 예시). §6의 `Fan_Activity_Pattern__c` 값이 이 조건을 충족한다.

| Object | Field | 값 |
|---|---|---|
| `Recommendation__c` | `Recommended_Action__c` / `Reason__c` / `Status__c` | Membership Campaign / "재방문 3회, 누적 지출 124,000원으로 VIP 후보 조건 충족" / Pending |
| Slack 메시지 (김매니저 수신, 레코드 아님) | 내용 | "이루키님이 VIP 후보입니다. Membership Campaign을 확인해주세요. (재방문 3회 · 누적 지출 124,000원)" |

---

## 8. Scene 8 — 충성 팬 (멤버십 가입)

| Object | Field | 값 |
|---|---|---|
| Order | `Order_Type__c` / `Purchase_Channel__c` / Product2 / `Membership_Status__c` / `Membership_End_Date__c` | Membership Enrollment / 온라인 / 멤버십 - Standard / Active / 2027-06-01 |
| `Recommendation__c` (§7) | `Status__c` | Pending → **Executed**로 갱신 |
| Person Account | `Current_Segment__c` | Active Fan 유지 (`00_STORY.md` §6 Current Segment/Life Cycle 값에는 "충성 팬"이라는
  별도 값이 없다) |
| Person Account | `Engagement_Level__c` | 개념적으로는 "충성"·"멤버십" 단계에 해당하지만, 계산 로직이 아직 TBD(`03_SYSTEM.md` §5)이므로 이 Demo에서는 값을 확정해 채우지 않는다 |

---

## 9. 전체 타임라인 요약 (QA용)

| 날짜 | 이벤트 |
|---|---|
| 2026-04-20 | 가입 (New Fan) |
| 2026-04-21 | SNS 반응 (문태양) |
| 2026-05-02 | 티켓 구매 + 첫 직관 (Active Fan 전환) |
| 2026-05-16 | 재방문 + 첫 굿즈 구매(문태양 유니폼) + Favorite Player Campaign 추천 |
| 2026-05-30 | 재방문(3회차) |
| 2026-05-31 | Fan Activity Pattern 갱신 → VIP 후보 감지 → Slack 알림 |
| 2026-06-01 | 멤버십 가입 (Membership Campaign 추천 Executed) |

> 혜준은 이 표의 날짜 순서가 실제 Org 데이터와 정확히 일치하는지(특히 Admission이
> Order 이후에 생성되는지) 검증한다(`03_HYEJUNE.md` Week 2).

---

## 10. Future Scope

- VIP 후보 임계값(재방문 3회, 지출 100,000원)은 Demo용 예시 값이다 — 실제 운영
  기준은 Business 논의 후 `05_DECISIONS.md`에 별도로 기록한다.
- 배경 Fan(박서연·김도현·최민재)의 상세 데이터는 필요 시 이 문서에 추가한다.
