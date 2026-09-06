# Cloud Alpacas — Org 구축용 더미 데이터

> 출처: `🦙 CloudAlpacas - 메타데이터 기록` 구글시트 **Object 시트** 기준 (2026-08 최신 결정 반영).
> **의존 관계(생성 순서)대로** 정렬했습니다 — 위에서부터 순서대로 넣으면 Lookup/Master-Detail 참조가 끊기지 않습니다.
>
> - ⚙️ = Roll-Up Summary / Formula → **직접 입력하지 마세요.** 자식 레코드를 만들면 자동으로 채워집니다.
> - `User(Staff)`는 김매니저 로그인 계정이라 더미 데이터 대상이 아닙니다.
> - Picklist는 **가능한 모든 값이 한 번씩은 나오도록** 레코드를 배치했습니다 — 값이 실제로 저장되는지 이걸로 한 번에 검증할 수 있습니다.

---

## 등장 인물 요약

| 팬 | 한 줄 설명 | 데모에서의 역할 |
|---|---|---|
| **이루키** | SNS로 유입 → 티켓 → 직관 → 굿즈 → 재방문 → 멤버십 | Demo 주인공 (Scene 1~8) |
| **박서연** | 지인 추천으로 가입한 평범한 활동 팬 | 배경 팬, Dashboard 목록 채우기 |
| **김도현** | 티켓을 샀지만 경기 취소로 환불 → 이탈 조짐 | 환불 · At-Risk 시나리오 |
| **최민재** | 가입만 하고 활동이 없는 팬 | Dormant · First Ticket Campaign 대상 |
| **정하윤** | 시즌권 보유 VIP | Fan_Value_Tier = VIP, 시즌권 케이스 |

---

## 1. Contact (Player) — RecordType = Player

| Last Name | Position__c | Uniform_Number__c |
|---|---|---|
| 문태양 | 투수 | 21 |
| 강도윤 | 내야수 | 7 |
| 이서준 | 포수 | 2 |
| 박현우 | 외야수 | 33 |

> Person Account의 `Favorite_Player__c`, Product2의 `Related_Player__c`가 참조하므로 **가장 먼저** 만듭니다. Position 4종을 한 번씩 다 씁니다.

---

## 2. Person Account (Fan)

| Name | PersonEmail | Acquisition_Channel__c | Favorite_Player__c | Current_Segment__c | Fan_Value_Tier__c | Engagement_Level__c | Engagement_Score__c | Opt-In |
|---|---|---|---|---|---|---|---|---|
| 이루키 | ruki@example.com | SNS | 문태양 | New Fan | 일반 | (비워둠) | (비워둠) | Email/SMS/Push/Kakao 전부 |
| 박서연 | seoyeon@example.com | 지인 추천 | 이서준 | Active Fan | 우수 | 활동 팬 | 65 | Email, Push |
| 김도현 | dohyun@example.com | 검색 | 강도윤 | At-Risk Fan | 일반 | 관심 팬 | 38 | Email |
| 최민재 | minjae@example.com | 오프라인 | (없음) | Dormant Fan | 일반 | 가입 팬 | 12 | (전부 해제) |
| 정하윤 | hayoon@example.com | SNS | 문태양 | Active Fan | VIP | 핵심 팬 | 92 | Email/SMS/Push/Kakao 전부 |

> - `Engagement_Level__c` / `Engagement_Score__c`는 **계산 공식 미확정(2026-08 결정)** 입니다. 이루키는 데모 원칙대로 비워두고, 나머지 4명에만 필드 동작 확인용 임의값을 넣으세요 — **운영 공식이 아닙니다.**
> - `Segment_Updated_Date__c` / `Consent_Updated_Date__c`는 13번 Fan_Segment_History의 최신 날짜와 맞춰주세요.
> - `Current_Segment__c` 6개 값 중 `Churned Fan` / `Unreachable Fan`은 이 세트에 없습니다 — 필요하면 최민재를 Churned로 한 번 바꿔보며 테스트하세요.

---

## 3. Product2

| Name | RecordType | Category__c | Tier__c | Related_Player__c | IsActive |
|---|---|---|---|---|---|
| 티켓 - 외야석 | Ticket | — | — | (없음) | ✔ |
| 티켓 - 1루 응원석 | Ticket | — | — | (없음) | ✔ |
| 2026 시즌권 - 외야석 | Season Pass | — | — | (없음) | ✔ |
| 멤버십 - Standard | Membership | — | Standard | (없음) | ✔ |
| 멤버십 - Premium | Membership | — | Premium | (없음) | ✔ |
| 문태양 유니폼(홈) | Goods | Uniform | — | 문태양 | ✔ |
| 문태양 인형 | Goods | Plush | — | 문태양 | ✔ |
| 팀 포토카드 세트 | Goods | Photo Card | — | (없음) | ✔ |

> RecordType 4종을 모두 씁니다. `Category__c`는 `Cheering Item / Living Goods / Accessory / Other`가 아직 안 쓰였으니, 값 검증이 필요하면 굿즈를 1~2개 더 얹으세요.

---

## 4. PricebookEntry (Standard Price Book)

| Product2 | UnitPrice | IsActive |
|---|---|---|
| 티켓 - 외야석 | 10,000 | ✔ |
| 티켓 - 1루 응원석 | 15,000 | ✔ |
| 2026 시즌권 - 외야석 | 350,000 | ✔ |
| 멤버십 - Standard | 60,000 | ✔ |
| 멤버십 - Premium | 120,000 | ✔ |
| 문태양 유니폼(홈) | 89,000 | ✔ |
| 문태양 인형 | 22,000 | ✔ |
| 팀 포토카드 세트 | 5,000 | ✔ |

> **가격이 없으면 OrderItem을 추가할 수 없습니다.** Order 만들기 전에 8건 전부 등록하세요.

---

## 5. Season__c

| Name | Total_Games__c | Played_Games__c |
|---|---|---|
| 2025 시즌 | 144 | ⚙️ 자동 |
| 2026 시즌 | 144 | ⚙️ 자동 (Game__c.Status__c = Played COUNT) |

> `Played_Games__c`는 입력 금지 — 지금 0으로 보여도 정상입니다. 2025 시즌은 `Fan_Activity_Pattern__c`의 **Fan+Season 중복 방지 규칙**을 테스트하려고 같이 만듭니다.

---

## 6. Game__c

| Game_Date__c | Opponent__c | Result__c | Season__c | Home_Away__c | Status__c |
|---|---|---|---|---|---|
| 2026-05-02 18:30 | 레드폭스 | Win | 2026 시즌 | Home | Played |
| 2026-05-16 17:00 | 블루웨일스 | Loss | 2026 시즌 | Home | Played |
| 2026-05-30 18:30 | 스톰이글스 | Draw | 2026 시즌 | Away | Played |
| 2026-06-13 18:30 | 그린드래곤스 | (비워둠) | 2026 시즌 | Home | **Cancelled** |
| 2026-06-20 17:00 | 선더버즈 | (비워둠) | 2026 시즌 | Away | Scheduled |

> 저장 후 5번으로 돌아가 `2026 시즌`의 `Played_Games__c`가 **3**이 됐는지 확인하세요 — Cancelled와 Scheduled가 빠져야 정상입니다. 이 값이 관람률(`Attendance_Rate__c`)의 분모입니다.

---

## 7. Order

Order는 `Draft`로 만들고 → 8번 OrderItem을 넣은 뒤 → `Activated`로 바꿉니다.

| # | Order_Type__c | Fan (Account) | EffectiveDate | Game__c | Purchase_Channel__c | Payment_Status__c | Coverage Start / End | Membership_Status__c |
|---|---|---|---|---|---|---|---|---|
| ① | Ticket Purchase | 이루키 | 2026-05-02 | 05-02 레드폭스 | Online | Paid | — | — |
| ② | Ticket Purchase | 이루키 | 2026-05-16 | 05-16 블루웨일스 | Online | Paid | — | — |
| ③ | Goods Purchase | 이루키 | 2026-05-16 | (없음) | Stadium | Paid | — | — |
| ④ | Ticket Purchase | 이루키 | 2026-05-30 | 05-30 스톰이글스 | Online | Paid | — | — |
| ⑤ | Membership Enrollment | 이루키 | 2026-06-01 | (없음) | Online | Paid | 2026-06-01 ~ 2027-06-01 | Active |
| ⑥ | Ticket Purchase | 박서연 | 2026-05-02 | 05-02 레드폭스 | Stadium | Paid | — | — |
| ⑦ | Ticket Purchase (시즌권) | 정하윤 | 2026-04-01 | (없음) | Online | Paid | 2026-04-01 ~ 2026-10-31 | — |
| ⑧ | Ticket Purchase | 김도현 | 2026-06-01 | 06-13 그린드래곤스 | Online | **Refunded** | — | — |
| ⑨ | Membership Enrollment | 박서연 | 2025-06-01 | (없음) | Stadium | Paid | 2025-06-01 ~ 2026-06-01 | **Expired** |

> - ⑧은 **경기 취소 환불 케이스**입니다: `Refund_Date__c` = 2026-06-14, `Refund_Reason__c` = `[Ticket] 경기취소`. 12번 `Total_Spend__c` 집계에서 빠져야 합니다.
> - ⑨는 `Membership_Status__c` = Expired를 확인하는 용도(만료된 작년 멤버십)입니다.
> - ⚠️ **확인 필요**: `Order_Type__c` Picklist에 `Season Pass` 값이 없습니다. ⑦처럼 시즌권을 Ticket Purchase로 담을지, Picklist 값을 추가할지 승우와 정해야 합니다.

---

## 8. OrderItem

| Order | Product2 | Quantity | Section__c | Row__c | Seat_Number__c | Current_Owner__c | Transfer_Status__c |
|---|---|---|---|---|---|---|---|
| ① 이루키 Ticket | 티켓 - 외야석 | 1 | 외야석 | 15 | 15 | 이루키 | Not Transferred |
| ② 이루키 Ticket | 티켓 - 1루 응원석 | 1 | 1루 응원석 | 7 | 12 | 이루키 | Not Transferred |
| ③ 이루키 Goods | 문태양 유니폼(홈) | 1 | — | — | — | 이루키 | Not Transferred |
| ④ 이루키 Ticket | 티켓 - 외야석 | 1 | 외야석 | 20 | 3 | 이루키 | Not Transferred |
| ⑤ 이루키 Membership | 멤버십 - Standard | 1 | — | — | — | 이루키 | Not Transferred |
| ⑥ 박서연 Ticket | 티켓 - 외야석 | 1 | 외야석 | 15 | 16 | 박서연 | Not Transferred |
| ⑦ 정하윤 시즌권 | 2026 시즌권 - 외야석 | 1 | 외야석 | 3 | 8 | 정하윤 | Not Transferred |
| ⑧ 김도현 Ticket | 티켓 - 1루 응원석 | 2 | 1루 응원석 | 11 | 21 | **최민재** | **Transferred** |
| ⑨ 박서연 Membership | 멤버십 - Premium | 1 | — | — | — | 박서연 | Not Transferred |

> ⑧은 김도현이 산 티켓을 최민재에게 양도한 케이스입니다 — `Current_Owner__c`가 구매자와 다르고 `Transfer_Status__c` = Transferred. **"구매자 ≠ 입장자"가 실제로 표현되는지** 확인하는 유일한 레코드입니다.

---

## 9. Attendance_Record__c ← **Admission__c보다 먼저!**

| Fan__c | Total_Admissions__c | First_Admission_Date__c | Last_Admission_Date__c |
|---|---|---|---|
| 이루키 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |
| 박서연 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |
| 김도현 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |
| 최민재 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |
| 정하윤 | ⚙️ 자동 | ⚙️ 자동 | ⚙️ 자동 |

> **`Fan__c`만 채우고 저장하세요.** 나머지 3개는 Roll-Up Summary입니다. 팬당 1건만 — Validation Rule로 막습니다. 김도현/최민재는 입장 기록이 0건이라 값이 비어 있는 게 정상입니다.

---

## 10. Admission__c

| Fan__c | Game__c | Order_Item__c | Admission_Time__c | Gate__c | Attendance_Record__c |
|---|---|---|---|---|---|
| 이루키 | 05-02 레드폭스 | ① 외야석 15열 15번 | 2026-05-02 17:50 | Gate 2 | 이루키 |
| 이루키 | 05-16 블루웨일스 | ② 1루 7열 12번 | 2026-05-16 16:35 | Gate 1 | 이루키 |
| 이루키 | 05-30 스톰이글스 | ④ 외야석 20열 3번 | 2026-05-30 18:05 | Gate 2 | 이루키 |
| 박서연 | 05-02 레드폭스 | ⑥ 외야석 15열 16번 | 2026-05-02 18:10 | Gate 3 | 박서연 |
| 정하윤 | 05-02 레드폭스 | ⑦ 시즌권 | 2026-05-02 17:40 | Gate 4 | 정하윤 |
| 정하윤 | 05-16 블루웨일스 | ⑦ 시즌권 | 2026-05-16 16:20 | Gate 4 | 정하윤 |

> - 저장 후 9번으로 돌아가 이루키의 `Total_Admissions__c` = **3**, `First` = 05-02, `Last` = 05-30이 됐는지 확인 — 되면 Master-Detail + Roll-Up이 정상입니다.
> - 정하윤은 **시즌권 OrderItem 1건으로 여러 번 입장**합니다. 티켓 1장 = 입장 1회를 강제하는 규칙이 있다면 여기서 걸리니, 시즌권 처리 방식과 함께 확인하세요.
> - 김도현은 경기가 취소돼서 입장 기록이 없습니다(환불 시나리오).

---

## 11. Engagement_Signal__c

| Fan__c | Signal_Type__c | Source__c | Player__c | Signal_Date__c |
|---|---|---|---|---|
| 이루키 | SNS Click | Instagram | 문태양 | 2026-04-21 20:15 |
| 이루키 | Video View | YouTube | 문태양 | 2026-04-25 22:40 |
| 박서연 | App Open | (없음) | (없음) | 2026-05-10 09:00 |
| 김도현 | SNS Click | Instagram | 강도윤 | 2026-05-28 13:20 |
| 정하윤 | Video View | YouTube | 문태양 | 2026-06-05 21:10 |

> Signal_Type 3종을 모두 씁니다. 이루키의 2건이 `Favorite_Player__c` = 문태양으로 설정한 근거입니다.

---

## 12. Fan_Activity_Pattern__c (Fan + Season 조합당 1건)

| Fan__c | Season__c | Games_Attended__c | Goods_Purchases__c | Total_Spend__c | Attendance_Rate__c | Analyzed_Date__c |
|---|---|---|---|---|---|---|
| 이루키 | 2026 시즌 | 3 | 1 | 124,000 | ⚙️ 자동 | 2026-05-31 |
| 박서연 | 2026 시즌 | 1 | 0 | 10,000 | ⚙️ 자동 | 2026-05-31 |
| 박서연 | 2025 시즌 | 0 | 0 | 120,000 | ⚙️ 자동 | 2025-12-31 |
| 정하윤 | 2026 시즌 | 2 | 0 | 350,000 | ⚙️ 자동 | 2026-05-31 |
| 김도현 | 2026 시즌 | 0 | 0 | **0** | ⚙️ 자동 | 2026-06-30 |

> - **이루키 124,000원 계산**: 티켓 3건(10,000 + 15,000 + 10,000) + 굿즈 1건(89,000). 멤버십 60,000원은 분석일(05-31) 이후 거래라 빠집니다. → **재방문 3회 + 누적 지출 10만원 이상** = VIP 후보 조건 충족.
> - **김도현 0원**: 유일한 Order가 Refunded라 집계에서 빠져야 합니다. 이 레코드가 환불 제외 로직의 검증 포인트입니다.
> - **박서연 2건**은 같은 팬 + 다른 시즌 → 저장돼야 합니다. 여기에 `박서연 / 2026 시즌`을 한 번 더 만들어보면 **중복 방지 규칙이 막는지** 확인할 수 있습니다.
> - `Attendance_Rate__c`는 `Games_Attended__c ÷ Season.Played_Games__c × 100` Formula입니다. 2026 시즌 Played = 3이므로 이루키는 100%, 정하윤 66.7%로 나와야 합니다. **2025 시즌은 Played가 0이라 나누기 오류가 날 수 있으니** 박서연 2025 레코드로 그 동작을 확인해보세요.

---

## 13. Fan_Segment_History__c

| Fan__c | Segment__c | Changed_Date__c | Reason__c |
|---|---|---|---|
| 이루키 | New Fan | 2026-04-20 10:00 | 최초 가입 |
| 이루키 | Active Fan | 2026-05-02 17:50 | 첫 직관 완료 |
| 박서연 | New Fan | 2025-03-15 11:20 | 최초 가입 |
| 박서연 | Active Fan | 2025-06-01 19:00 | 첫 직관 완료 |
| 김도현 | At-Risk Fan | 2026-07-01 00:00 | 60일 무활동 |
| 최민재 | Dormant Fan | 2026-08-01 00:00 | 90일 무활동 |
| 정하윤 | Active Fan | 2026-04-01 14:00 | 시즌권 구매 |

> Life Cycle(`Current_Segment__c`) 변화만 기록합니다 — Engagement Level / Fan Value 변경은 **넣지 않습니다**(3축 분리 원칙, 2026-08 결정).
> 각 팬의 최신 행이 2번 Person Account의 `Current_Segment__c`와 일치해야 합니다.

---

## 14. Recommendation__c

| Fan__c | Recommended_Action__c | Reason__c | Status__c |
|---|---|---|---|
| 이루키 | Welcome Message | 최초 가입 | Executed |
| 이루키 | Favorite Player Campaign | 문태양 관련 굿즈 첫 구매 | Executed |
| 이루키 | Membership Campaign | 재방문 3회, 누적 지출 124,000원으로 VIP 후보 조건 충족 | Pending |
| 최민재 | First Ticket Campaign | 가입 후 90일간 티켓 구매 없음 | Pending |
| 김도현 | First Visit Guide | 티켓 구매 후 경기 취소로 미방문 | Dismissed |
| 정하윤 | First Merchandise Campaign | 시즌권 보유, 굿즈 구매 이력 없음 | Pending |

> NBA 6종과 Status 3종을 모두 한 번씩 씁니다. **이루키의 Membership Campaign(Pending)** 이 Scene 7의 Aha 모먼트 레코드입니다 — Scene 8에서 Executed로 바뀝니다.

---

## 15. Benefit__c

| Fan__c | Benefit_Type__c | Recommendation__c | Status__c | Issued / Used / Expiration Date |
|---|---|---|---|---|
| 이루키 | Discount | Favorite Player Campaign | Issued | 2026-05-16 / — / 2026-08-16 |
| 이루키 | Membership Day Invite | Membership Campaign | Issued | 2026-06-01 / — / 2026-12-31 |
| 박서연 | Coupon | (없음) | Used | 2026-05-10 / 2026-05-20 / 2026-08-10 |
| 김도현 | Early Access | (없음) | Expired | 2026-03-01 / — / 2026-04-01 |
| 정하윤 | Discount | First Merchandise Campaign | Issued | 2026-06-10 / — / 2026-09-10 |

> Benefit_Type 4종, Status 3종을 모두 씁니다. `Recommendation__c`를 연결하려면 **14번을 먼저** 만들어야 합니다.

---

## 16. Campaign

| Name | Type | Status | StartDate / EndDate | IsActive |
|---|---|---|---|---|
| Welcome Campaign | Email | In Progress | 2026-01-01 / 2026-12-31 | ✔ |
| First Ticket Campaign | Email | In Progress | 2026-03-01 / 2026-12-31 | ✔ |
| Favorite Player Campaign | Email | Completed | 2026-05-01 / 2026-05-31 | ✔ |
| Membership Campaign | Email | Planned | 2026-06-01 / 2026-12-31 | ✔ |

---

## 17. CampaignMember

| Campaign | Contact (Person Account의 숨은 Contact) | Status |
|---|---|---|
| Welcome Campaign | 이루키 | Sent |
| Welcome Campaign | 최민재 | Sent |
| First Ticket Campaign | 최민재 | Sent |
| Favorite Player Campaign | 이루키 | Responded |
| Membership Campaign | 정하윤 | Responded |

> Person Account를 CampaignMember에 넣으면 **숨은 Contact**로 잡힙니다 — 화면에서 어떻게 보이는지 혜준이 한 번 확인해야 합니다.

---

## 18. Notification_Log__c

| Fan__c | Campaign__c | Channel__c | Content__c | Sent_Date__c |
|---|---|---|---|---|
| 이루키 | Welcome Campaign | Email | "Cloud Alpacas에 오신 것을 환영합니다, 이루키님!" | 2026-04-20 10:05 |
| 이루키 | Favorite Player Campaign | Push | "문태양 선수 신상 굿즈가 나왔어요 ⚾" | 2026-05-16 12:00 |
| 최민재 | First Ticket Campaign | SMS | "최민재님, 첫 경기 관람 10% 할인 쿠폰이 도착했어요" | 2026-05-25 12:00 |
| 정하윤 | Membership Campaign | Kakao AlimTalk | "정하윤님, 시즌권 회원 전용 멤버십 데이에 초대합니다" | 2026-06-10 11:00 |
| 박서연 | (없음) | Email | "박서연님의 멤버십이 만료되었습니다" | 2026-06-01 09:00 |

> Channel 4종을 모두 씁니다. 이건 **팬에게 나가는 알림**이고, 김매니저가 받는 Slack 알림과는 목적이 다릅니다.

---

## 19. Case (Inquiry)

| Subject | Origin | Status | Fan (Account) | Related_Order__c |
|---|---|---|---|---|
| 티켓 환불 문의 | Phone | New | 김도현 | ⑧ 김도현의 환불 Order |
| 좌석 양도 방법 문의 | Web | Working | 김도현 | ⑧ 김도현의 환불 Order |
| 멤버십 결제 오류 문의 | Email | Escalated | 박서연 | ⑨ 박서연의 Membership Order |
| 굿즈 배송 지연 문의 | Email | Closed | 이루키 | ③ 이루키의 Goods Order |

> Origin 3종, Status 4종을 모두 씁니다. 첫 번째 Case에서 `Related_Order__c`를 눌렀을 때 `Payment_Status__c = Refunded`가 바로 보이는지 — 이게 이번에 새로 생긴 연결 구조의 핵심 검증 포인트입니다.

---

## 입력 순서 체크리스트

```
 1. Contact (Player)              4건
 2. Person Account (Fan)          5건
 3. Product2                      8건
 4. PricebookEntry                8건   ← 가격 없으면 OrderItem 불가
 5. Season__c                     2건
 6. Game__c                       5건   ← Played 3건 확인
 7. Order (Draft로 생성)          9건
 8. OrderItem                     9건   → 그다음 Order를 Activated로
 9. Attendance_Record__c          5건   ← Admission보다 먼저!
10. Admission__c                  6건
11. Engagement_Signal__c          5건
12. Fan_Activity_Pattern__c       5건
13. Fan_Segment_History__c        7건
14. Recommendation__c             6건
15. Benefit__c                    5건   ← Recommendation 먼저
16. Campaign                      4건
17. CampaignMember                5건
18. Notification_Log__c           5건   ← Campaign 먼저
19. Case                          4건   ← Order 먼저
                                 ─────
                                 총 107건
```

---

## 승우 · 혜준과 확인할 것

1. **`Order_Type__c`에 Season Pass 값이 없습니다** — 시즌권(⑦)을 Ticket Purchase로 담을지, Picklist 값을 추가할지.
2. **`Membership_End_Date__c`와 `Coverage_End_Date__c`가 시트에 둘 다 남아 있습니다** — ⑤ 결정대로면 Coverage로 통합됐어야 합니다. 어느 쪽을 쓸지 정리 필요.
3. **`Purchase_Channel__c`가 `Online / Stadium`(영문)으로 바뀌었습니다** — 기존 `docs/data/*.md`는 `온라인 / 구장 굿즈샵` 기준이라 문서 갱신이 필요합니다.
4. **시즌권 1건으로 여러 번 입장**(정하윤)이 가능한 구조인지 — `Admission__c.Order_Item__c`에 같은 OrderItem이 2번 들어갑니다.
5. **`Attendance_Rate__c`의 0으로 나누기** — 박서연 / 2025 시즌 레코드로 동작 확인.
