# 06. Relationship Guide — 이 Object들은 왜 이렇게 연결되나요?

**이 페이지가 답하는 질문**: 왜 이 관계가 이렇게 설계됐나요?

> 이건 ERD가 아니다. Data Dictionary도 아니다. **"왜"에만 집중한 초보자용
> 가이드**다 — 정확한 관계는 [`03_ERD.md`](./03_ERD.md), 전체 그림은
> [`05_OBJECT_MAP.md`](./05_OBJECT_MAP.md)를 본다. 이 문서를 다 읽고 나면
> "이건 왜 이렇게 연결돼 있어요?"라는 질문이 더 안 나오는 게 목표다.
>
> 질문마다 4가지를 같은 순서로 설명한다: **비즈니스 의미 → 왜 이렇게
> 설계했나 → 왜 더 단순한 대안을 쓰지 않았나 → MVP에 어떻게 기여하나.**

---

### 1. Product2와 Order Item은 뭐가 다른가요?

| | |
|---|---|
| 비즈니스 의미 | Product2는 "우리가 팔 수 있는 것"(카탈로그), Order Item은 "이 팬이 실제로 산 것"이다. |
| 왜 이렇게 설계했나 | Salesforce 표준 판매 구조(Product2 + Price Book + Order)를 그대로 썼다 — 카탈로그와 실제 판매 기록을 분리하는 건 이미 검증된 표준 패턴이다(Decision 003). |
| 왜 더 단순한 대안을 쓰지 않았나 | Order에 상품명을 텍스트로 적는 방법도 있었지만, 그러면 가격이 바뀌었을 때 이전 주문 기록이 같이 바뀌어버리고, 상품별 판매량 집계도 안 된다. |
| MVP에 어떻게 기여하나 | 좌석 등급별·멤버십 등급별 가격을 Price Book Entry로 바로 관리할 수 있어, Demo에 필요한 가격 로직을 표준 기능만으로 구현했다. |

### 2. Order는 왜 Admission과 분리되어 있나요?

| | |
|---|---|
| 비즈니스 의미 | Order는 "구매했다", Admission은 "실제로 게이트를 통과해 입장했다"는 뜻이다. |
| 왜 이렇게 설계했나 | "몇 번 왔는가"(집계)와 "언제 왔는가"(개별 사건)를 구분해야 했고, 티켓 업무 흐름도 "입장"을 구매와 별개 단계로 다룬다(01_PROJECT.md §3.1). |
| 왜 더 단순한 대안을 쓰지 않았나 | Order에 "Status = 입장완료" 값을 추가하는 방법도 가능했지만, 그러면 양도된 티켓을 다른 사람이 입장하는 경우나 게이트·시각 같은 입장 자체의 정보를 담을 곳이 없어진다. |
| MVP에 어떻게 기여하나 | "첫 직관 완료 → Active Fan 전환" Flow가 Admission 생성을 트리거로 쓴다. Order만으로는 이 자동화를 만들 수 없었다. |

### 3. Inquiry와 Case는 뭐가 다른가요?

| | |
|---|---|
| 비즈니스 의미 | Inquiry는 "팬 문의"라는 업무 개념(Business Entity)이고, Case는 그 개념을 구현한 실제 Salesforce Object 이름이다 — 같은 것을 부르는 두 가지 이름에 가깝다. |
| 왜 이렇게 설계했나 | Case는 접수→분류→해결까지 문의 처리의 전체 생애주기를 이미 갖춘 표준 Object라, Custom Object를 새로 만들 이유가 없었다(Decision 003). |
| 왜 더 단순한 대안을 쓰지 않았나 | Custom Object로 새로 만들면 필드를 마음대로 설계할 수 있지만, Case가 이미 제공하는 Status/Origin/Priority 등을 처음부터 다시 만드는 셈이라 오히려 중복 설계가 된다. |
| MVP에 어떻게 기여하나 | `Related_Order__c` 필드 하나만 추가해서 "이 문의가 어떤 거래에 대한 것인지"만 연결하면 충분했다(03_SYSTEM.md §2.8). |

### 4. Fan Activity Pattern은 왜 Order Item과 직접 연결되어 있지 않나요?

| | |
|---|---|
| 비즈니스 의미 | Fan Activity Pattern은 원본 거래 기록이 아니라, 여러 활동(구매·관람·가입·수신)을 모아 만든 **분석 결과**다. |
| 왜 이렇게 설계했나 | 팬의 행동이 아니라 "구단(시스템)이 생성한 결과물"이라는 점에서 Recommendation과 같은 성격(Analytics)으로 분류했다(01_PROJECT.md §3.1). |
| 왜 더 단순한 대안을 쓰지 않았나 | Order Item에 팬의 누적 통계 필드를 직접 넣는 방법도 있었지만, 그러면 "이 분석이 언제 실행됐는지" 시점을 남길 수 없고, 여러 Order·Admission을 종합하는 로직을 거래 1건짜리 레코드에 억지로 넣는 셈이 된다. |
| MVP에 어떻게 기여하나 | VIP 후보 감지 Flow가 이 집계 결과 하나만 보고 판단한다 — 원본 거래 레코드마다 매번 조건을 검사하면 로직이 중복된다. |

### 5. Fan Activity Pattern은 왜 Recommendation으로 이어지나요?

| | |
|---|---|
| 비즈니스 의미 | 활동 패턴이 특정 조건(재방문 3회 이상 + 지출 임계값)을 만족하면, "이 팬에게 다음 행동을 제안해야 한다"는 신호가 된다. |
| 왜 이렇게 설계했나 | 00_STORY.md §7의 Next Best Action 표를 그대로 자동화한 것이다(03_SYSTEM.md §4.5 VIP 후보 감지 Flow). |
| 왜 더 단순한 대안을 쓰지 않았나 | 사람이 매번 리포트를 열어 판단하는 방법도 있었지만, 그게 바로 이 프로젝트가 풀려는 문제였다 — "VIP가 될 가능성이 높은 팬도 엑셀을 정리한 후에야 발견한다"(00_STORY.md Pain Point 4). |
| MVP에 어떻게 기여하나 | 조건이 충족되면 Recommendation 생성과 동시에 김매니저에게 Slack 알림이 간다 — Demo의 핵심 장면(VIP 후보 감지 Scene) 중 하나다. |

### 6. Recommendation은 왜 Notification으로 이어지나요?

| | |
|---|---|
| 비즈니스 의미 | Recommendation은 **내부 판단**("이 팬에게 멤버십을 제안하자")이고, Notification은 **팬에게 실제로 나가는 메시지**다. 받는 사람도 목적도 다르다. |
| 왜 이렇게 설계했나 | "판단"과 "발송"을 분리해야 "판단은 했지만 아직 안 보낸 것"과 "이미 보낸 것"을 구분할 수 있다(03_SYSTEM.md §4.3). |
| 왜 더 단순한 대안을 쓰지 않았나 | 하나의 레코드로 합칠 수도 있었지만, 그러면 Recommendation의 `Status__c`(Pending/Executed/Dismissed) 값이 의미가 없어진다 — 김매니저가 "이건 지금 보내지 말자"고 판단할 여지가 사라진다. |
| MVP에 어떻게 기여하나 | 김매니저가 Recommendation Panel에서 추천을 확인 후 실행 여부를 결정하고, 실행된 것만 Notification으로 남아 Fan Timeline에 쌓인다. |

### 7. Campaign은 왜 Person Account와 연결되어 있나요?

| | |
|---|---|
| 비즈니스 의미 | 팬이 특정 캠페인의 발송 대상이라는 뜻이다(CampaignMember를 통해 연결된다). |
| 왜 이렇게 설계했나 | 표준 Campaign/CampaignMember 구조를 그대로 썼다 — 마케팅 대상 선정과 발송 이력 관리가 이미 있는 표준 기능이다(01_PROJECT.md §6.1). |
| 왜 더 단순한 대안을 쓰지 않았나 | Person Account에 "참여 중인 캠페인" 텍스트 필드를 두는 방법도 있었지만, 그러면 한 팬이 여러 캠페인에 동시에 속하는 걸 표현할 수 없고, 캠페인별 반응률 같은 표준 리포트도 쓸 수 없다. |
| MVP에 어떻게 기여하나 | Welcome Campaign, VIP 후보 발견 시 Membership Campaign처럼, Flow가 조건에 따라 CampaignMember를 자동으로 추가하는 방식으로 이미 구현되어 있다(03_SYSTEM.md §4.4). |

### 8. Membership은 왜 Benefit과 연결되어 있나요?

| | |
|---|---|
| 비즈니스 의미 | 멤버십에 가입한 팬에게 회원 전용 혜택(할인, 선예매 등)이 발급된다는 뜻이다. |
| 왜 이렇게 설계했나 | `Benefit__c`는 마케팅·멤버십·굿즈에서 공통으로 쓰이는 "혜택" 개념 하나로 통합했다 — 멤버십은 그 발급 경로 중 하나일 뿐이다(01_PROJECT.md §3.1). |
| 왜 더 단순한 대안을 쓰지 않았나 | 멤버십 상품(Product2)에 "포함된 혜택" 필드를 직접 넣는 방법도 있었지만, 그러면 "혜택을 받았다"와 "실제로 썼다"를 구분할 수 없고, Recommendation을 통해 발급되는 다른 혜택과 한 화면에서 같이 볼 수 없다. |
| MVP에 어떻게 기여하나 | `Benefit__c.Status__c`(Issued/Used/Expired) 하나로, 멤버십 혜택이든 추천 혜택이든 같은 화면(Recommendation Panel)에서 관리할 수 있다. |

### 9. Ticket/Goods를 왜 별도 Object가 아니라 Product2 Record Type으로 만들었나요?

| | |
|---|---|
| 비즈니스 의미 | Ticket, Season Pass, Membership, Goods는 성격이 달라 보여도 전부 "우리가 파는 것"이라는 같은 카테고리다. |
| 왜 이렇게 설계했나 | 표준 Product2 + Price Book을 그대로 쓰고, Record Type으로 4종류를 구분했다(Decision 003, 03_SYSTEM.md §2.3). |
| 왜 더 단순한 대안을 쓰지 않았나 | 여기서는 반대로 "왜 더 복잡한 대안(Object 4개)을 안 썼나"가 맞는 질문이다 — `Ticket__c`, `Goods__c`처럼 따로 만들 수도 있었지만, 그러면 "이 팬이 지금까지 얼마나 썼는지" 같은 공통 집계를 위해 매번 Object 4개를 각각 조회해야 한다. |
| MVP에 어떻게 기여하나 | Baby Team이 Object를 4개씩 따로 배우지 않고 Product2 하나의 Record Type 개념만 익히면 된다 — Object 개수를 줄이는 것 자체가 이 프로젝트가 반복해서 따르는 원칙이다(Decision 005, 006). |

---

## 관련 문서

- [`05_OBJECT_MAP.md`](./05_OBJECT_MAP.md) — 이 관계들이 그림으로 어떻게
  이어지는지.
- [`03_ERD.md`](./03_ERD.md) — 정확한 관계와 방향.
- `docs/01_PROJECT.md` §3, §6 / `docs/05_DECISIONS.md` — 이 문서의 모든 "왜"의
  원본 출처. 더 깊게 알고 싶으면 여기로 간다.
