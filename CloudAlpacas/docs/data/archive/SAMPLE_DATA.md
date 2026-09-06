# Cloud Alpacas — Org 구축용 더미 데이터 예시

> **Archived (2026-08-17).** 이 문서의 내용은 같은 날 이후 작성된 `docs/data/SAMPLE_DATA_v2_1.md`에 더 완결된 형태로 포함되어 있다. 새 작업은 `SAMPLE_DATA_v2_1.md`를 참고할 것 — 이 파일은 삭제하지 않고 기록용으로만 보관한다.

> `CloudAlpacas_메타데이터_기록.xlsx` Object 시트 기준. **의존 관계(생성 순서)대로** 정렬했습니다 —
> 위에서부터 순서대로 입력하면 Lookup/Master-Detail 참조가 끊기지 않습니다.
> 🆕 표시는 지난 논의에서 새로 추가된 Object/Field라 기존 `SAMPLE_DATA.md`/`DEMO_DATASETS.md`엔
> 없는 것들입니다. ⚙️는 Roll-Up Summary/Formula라 **직접 입력하면 안 되는** 필드입니다.

---

## 1. 🆕 Season__c (가장 먼저 — Game__c의 Master 부모)

| Name | Total_Games__c | Played_Games__c |
|---|---|---|
| 2026 시즌 상반기 | 72 | ⚙️ 자동(Game__c.Status__c=Played 집계) |
| 2026 시즌 하반기 | 72 | ⚙️ 자동 |

> Played_Games__c는 입력하지 마세요 — Game__c를 Status__c=Played로 만들면 자동으로 올라갑니다. 지금은 0으로 보여도 정상입니다(아직 연결된 Game이 없으니까요).

---

## 2. Contact (Player) — RecordType=Player

기존 `SAMPLE_DATA.md` §1 그대로 재사용 (신규 아님, 참고용 재게재)

| Name | Position__c | Uniform_Number__c |
|---|---|---|
| 문태양 | 투수 | 21 |
| 강도윤 | 내야수 | 7 |

---

## 3. 🆕 Game__c (Season__c 필요 — 순서상 1번 다음)

| Game_Date__c | Opponent__c | Result__c | 🆕 Season__c | 🆕 Home_Away__c | 🆕 Status__c |
|---|---|---|---|---|---|
| 2026-05-02 | 레드폭스 | Win | 2026 시즌 상반기 | Home | Played |
| 2026-06-20 | 선더버즈 | (비워둠) | 2026 시즌 상반기 | Away | Scheduled |

> 두 번째 예시(Scheduled)를 넣어봐야 `Played_Games__c` Roll-Up이 "전체가 아니라 진행된 것만" 세는 걸 직접 확인할 수 있습니다. Status__c=Cancelled 케이스도 하나 만들어서 관람률 계산에서 실제로 빠지는지 테스트해보세요.

---

## 4. Person Account (Fan)

기존 `DEMO_DATASETS.md`의 이루키 + 신규 필드 테스트용 샘플

| Name | Acquisition_Channel__c | Favorite_Player__c | Current_Segment__c | 🆕 Fan_Value_Tier__c | 🆕 Engagement_Level__c | 🆕 Engagement_Score__c |
|---|---|---|---|---|---|---|
| 이루키 | SNS | 문태양 | New Fan | 일반 | (비워둠, TBD) | (비워둠, TBD) |
| 박서연 | 지인 추천 | (없음) | Active Fan | 우수 | 활동 팬 | 65 |

> 이루키는 `DEMO_DATASETS.md` 원칙대로 Engagement 필드를 비워두고, 박서연은 **필드가 실제로 동작하는지 확인하는 용도로만** 임의값(65점, "활동 팬")을 넣어보세요 — 이건 데모 공식이 아니라 순수 테스트 값입니다.

---

## 5. Product2 — 🆕 Category__c 확장값 테스트용

기존 4개(`SAMPLE_DATA.md` §2.4)는 Uniform/Cheering Item/Accessory만 썼으니, 새로 늘어난 값 위주로 2개만 추가

| Name | RecordType | Category__c | Related_Player__c | 가격 |
|---|---|---|---|---|
| 문태양 인형 | Goods | 🆕 Plush | 문태양 | 22,000원 |
| 팀 포토카드 세트 | Goods | 🆕 Photo Card | (없음) | 5,000원 |

---

## 6. PricebookEntry

위 2개 상품에 대해 Standard Price Book에 가격만 등록하면 됩니다(22,000원 / 5,000원) — 별도 예시 표 불필요.

---

## 7. 🆕 Attendance_Record__c (Admission__c보다 먼저! Master-Detail 부모)

| Fan__c | Total_Admissions__c | First_Admission_Date__c | Last_Admission_Date__c |
|---|---|---|---|
| 이루키 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |
| 박서연 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |

> **레코드는 만들어야 하지만 저 3개 필드엔 아무 값도 입력하지 마세요.** Fan__c만 채우고 Save — 나머지는 Admission__c를 만들면 자동으로 채워집니다. (Welcome Campaign Flow가 완성되면 이 레코드는 Fan 가입 시 자동 생성되지만, 지금은 Flow 전이니 수동으로 먼저 만들어두는 겁니다.)

---

## 8. Order — 🆕 Payment_Status__c / Refund / Coverage 필드 테스트

| Order_Type__c | Purchase_Channel__c | Account | 🆕 Payment_Status__c | 🆕 Refund_Date__c | 🆕 Refund_Reason__c | 🆕 Coverage_Start/End_Date__c |
|---|---|---|---|---|---|---|
| Ticket Purchase | 온라인 | 이루키 | Paid | (비워둠) | (비워둠) | 해당없음 |
| Membership Enrollment | 구장 | 박서연 | Paid | (비워둠) | (비워둠) | 2026-06-01 ~ 2027-06-01 |

> **환불 시나리오도 하나 따로 테스트해보세요**: 아무 Order나 하나 더 만들어서 Payment_Status__c=Refunded, Refund_Date__c=오늘, Refund_Reason__c=단순변심으로 채워보고, Fan_Activity_Pattern__c.Total_Spend__c 계산 로직이 확정되면 이 Order가 실제로 집계에서 빠지는지 나중에 확인할 수 있게 남겨두세요.

---

## 9. OrderItem

기존 방식 그대로(`SAMPLE_DATA.md`/`DEMO_DATASETS.md` 패턴 재사용) — 좌석 정보만 채우면 됩니다.

| Order | Product2 | Section__c | Row__c | Seat_Number__c |
|---|---|---|---|---|
| 이루키의 Ticket Purchase | 티켓 - 외야석 | 외야 C구역 | 15열 | 15 |
| 박서연의 Membership Enrollment | 멤버십 - Standard | 해당없음 | 해당없음 | 해당없음 |

---

## 10. 🆕 Admission__c (Attendance_Record__c 먼저 만든 뒤에!)

| Fan__c | Game__c | Order_Item__c | Admission_Time__c | Gate__c | 🆕 Attendance_Record__c |
|---|---|---|---|---|---|
| 이루키 | 2026-05-02 vs 레드폭스 | 위 OrderItem | 2026-05-02 17:50 | Gate 2 | 이루키의 Attendance Record |
| 박서연 | 2026-05-02 vs 레드폭스 | (별도 OrderItem 필요) | 2026-05-02 18:10 | Gate 1 | 박서연의 Attendance Record |

> 저장하고 나서 7번의 Attendance_Record__c로 돌아가 보세요 — `Total_Admissions__c`가 자동으로 1이 돼 있으면 Roll-Up이 정상 동작하는 겁니다.

---

## 11. Engagement_Signal__c

| Fan__c | Signal_Type__c | Source__c | Player__c | Signal_Date__c |
|---|---|---|---|---|
| 이루키 | SNS Click | Instagram | 문태양 | 2026-04-21 |
| 박서연 | App Open | (없음) | (없음) | 2026-05-10 |

---

## 12. 🆕 Fan_Activity_Pattern__c (Period__c 대신 Season__c, Fan당+Season당 1건)

| Fan__c | 🆕 Season__c | Games_Attended__c | Goods_Purchases__c | Total_Spend__c | 🆕 Attendance_Rate__c | Analyzed_Date__c |
|---|---|---|---|---|---|---|
| 이루키 | 2026 시즌 상반기 | 3 | 1 | 124,000원 | ⚙️ 자동(Formula) | 2026-05-31 |
| 박서연 | 2026 시즌 상반기 | 1 | 0 | 15,000원 | ⚙️ 자동(Formula) | 2026-05-31 |

> `Attendance_Rate__c`는 Formula라 필드 자체가 화면에 안 보이거나 계산 불가로 나올 수 있습니다 — `Season__c.Played_Games__c`가 0이면 나누기 오류가 날 수 있으니, 3번(Game__c)에서 Status__c=Played인 레코드를 최소 1개는 먼저 만들어두세요.

---

## 13. Fan_Segment_History__c

| Fan__c | Segment__c | Changed_Date__c | Reason__c |
|---|---|---|---|
| 이루키 | New Fan | 2026-04-20 | 최초 가입 |
| 이루키 | Active Fan | 2026-05-02 | 첫 직관 완료 |

---

## 14. Recommendation__c

| Fan__c | Recommended_Action__c | Reason__c | Status__c |
|---|---|---|---|
| 이루키 | Favorite Player Campaign | 문태양 관련 굿즈 첫 구매 | Executed |
| 이루키 | Membership Campaign | 재방문 3회, 누적 지출 124,000원으로 VIP 후보 조건 충족 | Pending |

---

## 15. Benefit__c

| Fan__c | Benefit_Type__c | Recommendation__c | Status__c | Issued_Date__c |
|---|---|---|---|---|
| 이루키 | Discount | 위 Favorite Player Campaign 건 | Issued | 2026-05-16 |
| 박서연 | Coupon | (없음) | Issued | 2026-05-10 |

---

## 16. Notification_Log__c

| Fan__c | Channel__c | Content__c | Sent_Date__c |
|---|---|---|---|
| 이루키 | Email | "Cloud Alpacas에 오신 것을 환영합니다, 이루키님!" | 2026-04-20 |
| 박서연 | Push | "박서연님, 이번 주 홈경기 티켓 할인 중입니다" | 2026-05-25 |

---

## 17. Campaign / CampaignMember

| Campaign Name | Type |
|---|---|
| Welcome Campaign | Email |
| Membership Campaign | Email |

CampaignMember는 위 Campaign에 이루키/박서연을 각각 1명씩 추가하면 됩니다.

---

## 18. Case — 🆕 환불 문의 시나리오 테스트

| Subject | Origin | Status | Related_Order__c |
|---|---|---|---|
| 티켓 환불 문의 | Phone | New | 8번의 환불 테스트 Order |
| 멤버십 결제 오류 문의 | Email | Closed | 박서연의 Membership Order |

> 첫 번째 Case는 일부러 8번에서 만든 **환불 테스트 Order**와 연결해보세요 — Case 화면에서 `Related_Order__c`를 눌렀을 때 `Payment_Status__c=Refunded`가 바로 보이는지 확인하는 게 이번에 새로 생긴 연결 구조를 검증하는 핵심 포인트입니다.

---

## 입력 순서 체크리스트 (요약)

```
1. Season__c
2. Contact(Player) — 기존 데이터 재사용
3. Game__c (Season__c 연결)
4. Person Account
5. Product2 (신규 Category만)
6. PricebookEntry
7. Attendance_Record__c ← Admission보다 먼저!
8. Order
9. OrderItem
10. Admission__c (Attendance_Record__c 연결)
11. Engagement_Signal__c
12. Fan_Activity_Pattern__c (Season__c 연결)
13. Fan_Segment_History__c
14. Recommendation__c
15. Benefit__c
16. Notification_Log__c
17. Campaign/CampaignMember
18. Case (Related_Order__c 연결)
```