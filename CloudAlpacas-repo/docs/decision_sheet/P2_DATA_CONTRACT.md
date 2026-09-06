# Cloud Alpacas — P2 Data Contract

> **회의 메인 문서가 아니다.** 2026-08-18 회의는 `P2_TECHNICAL_DECISION_SHEET.md` 하나로
> 진행했고, 이 문서는 그 결정 이후 **실제 구현 단계에서 Owner / Related Record / Handoff를
> 확인하는 실행 기준**이다(Review Order 6번). A~K 결정 결과는 `05_DECISIONS.md`
> Decision 017·018을 따른다 — 아래 표에서 그 결정과 충돌하는 서술(예: Campaign
> RecordType 관련)은 결정 결과에 맞춰 갱신했다.
>
> "공통 영역 회의에서 확정해야 하는 건 Object 자체보다 **Relationship과 데이터의
> 주인**이다" — 이 문서는 그 결정을 기록하는 곳이다. `03_SYSTEM.md`가 "Object가
> 무엇인가"를 정의한다면, 이 문서는 **"그 Object의 실제 레코드를 누가 만들고, 다른
> 사람은 그걸 어떻게 참조하는가"**만 정의한다.
>
> ⚠️ Scenario ID는 `DEMO_DATA_STANDARD.md` §6.3 컨벤션(`SCN-B2B-001`)을 그대로
> 따랐다. 팀에서 `SCN-001`로 바꾸기로 했다면 이 문서 전체를 일괄 수정해야 한다.

---

## 1. 원칙

1. **각자 자기 영역의 Record만 만든다.** 다른 사람 영역의 Record가 필요하면, 새로 만들지 않고 그 사람이 만든 Record를 **참조(Lookup)** 한다.
2. **공유 Object(Person Account, Fan, Season, Game 등)의 필드는 담당자가 임의로 바꾸지 않는다.** 필요하면 아래 형식으로 제안 → 팀 합의 → 반영.
   ```
   [제안] {Object}에 {Field명} 필요
   이유:
   사용 Feature:
   영향 범위:
   ```
3. **모든 Record는 4개 정보를 남긴다**: `Owner` / `Scenario ID` / `Record Name` / `Related Record`. 개인 시트든 Org 레코드의 Description이든, 이 4개는 반드시 기록한다.
4. **마지막엔 반드시 End-to-End로 이어지는지 검증한다** — 한 사람의 Record만 잘 만들어져 있어도, 연결이 끊기면 Demo가 안 된다.

---

## 2. Feature Owner 지도

| Owner | 담당 | 책임 Object |
|---|---|---|
| A. 사라 | Fan 360 고도화 + B2B 연결 | Person Account(Fan), Fan Segment 관련 필드, Engagement/Fan Value |
| B. 혜준 | Collab360 + Lead | Partner Candidate(개념), Lead |
| C. 아론 | Account + Contact | Partner Account, 담당자 Contact |
| D. 은영 | Opportunity | Opportunity |
| E. 승우 | Product + Quote + Campaign | Product2(Sponsorship Package), Quote, Campaign |

---

## 3. Data Contract Table — SCN-B2B-001: d'Alba Sponsorship

> `P2_DUMMY_DATA_MASTER.md` §3에 있던 값을 그대로 쓰되, Owner와 Related Record를
> 명시해서 "누가 만들고 누가 참조하는지"를 표로 고정한다. 실제 작업 시트는 이 표
> 형식을 그대로 복사해서 쓰면 된다.

| Owner | Scenario ID | Object | Record Name | Related Record (참조만, 재생성 금지) |
|---|---|---|---|---|
| **A. 사라** | SCN-B2B-001 | Person Account × 11 | 이하은, 최유진, 강수아, 윤지아, 임소연, 오예린, 황서현, 송다인, 전하율, 곽나연, 노아름 | *(시작점 — 참조 없음)* |
| **A. 사라** | SCN-B2B-001 | Report | "10~30대 여성 팬 Fan Insight" | 위 11명 Person Account 집계 |
| **B. 혜준** | SCN-B2B-001 | Lead | d'Alba(달바) (김하나) | A의 Fan Insight Report — *Lookup 연결이 아니라 Description에 근거만 기록* (`[SCN-B2B-001] 10~30대 여성 팬층 × 뷰티/라이프스타일 관심 신호(SNS 반응률) 기반 Fit 가설`) |
| **C. 아론** | SCN-B2B-001 | Account | d'Alba(달바) | B의 Lead d'Alba(달바) (Lead Convert 결과 — **새로 만들지 않고 Convert로 생성**) |
| **C. 아론** | SCN-B2B-001 | Contact | 김하나 | C 자신의 Account d'Alba(달바) |
| **D. 은영** | SCN-B2B-001 | Opportunity | d'Alba(달바) × Cloud Alpacas — Advertising Sponsorship | C의 Account d'Alba(달바) (`AccountId` Lookup) |
| **E. 승우** | SCN-B2B-001 | Product2 | d'Alba 전광판 광고+Brand Day 패키지 | D의 Opportunity에 Product Line Item으로 연결 |
| **E. 승우** | SCN-B2B-001 | Quote | d'Alba Sponsorship Quote | D의 Opportunity (`OpportunityId` Lookup, Wireframe 확정) |
| **E. 승우** | SCN-B2B-001 | QuoteLineItem | d'Alba 전광판 광고+Brand Day 패키지 | E 자신의 Quote + E 자신의 Product2 (동일 Product2를 Opportunity Line Item과 Quote Line Item 양쪽에 재사용) |
| **E. 승우** | SCN-B2B-001 | Campaign | d'Alba Sponsorship Campaign | D의 Opportunity (`Primary Campaign Source`로 연결). Campaign 자체는 **Record Type = Collaboration**으로 생성(Decision 018-D 확정 — RecordType 방식) |
| **E. 승우** | SCN-B2B-001 | CampaignMember × 11 | 위 11명 | A의 Person Account 11명 + E 자신의 Campaign |

### 읽는 법 (예시)

> D(은영)가 Opportunity를 만들 때, "d'Alba(달바)"라는 Account를 새로 만들면 안 된다.
> 반드시 **C(아론)가 이미 만들어 둔 d'Alba(달바) Account를 검색해서 Lookup으로
> 연결**해야 한다. 만약 C가 아직 Account를 안 만들었다면, D는 자기 Opportunity를
> 못 만드는 게 정상이다 — 이게 "순서대로 이어 쓴다"는 의미다.

---

## 3.5 Handoff 예시 — "내가 뭘 하면 다음 사람이 뭘 하는가"

> §3 표를 그대로 읽으면 "누가 뭘 만드는지"는 알지만, "다음 사람이 그걸 받아서
> 정확히 뭘 하는지"는 안 보인다. 아래는 그 실행 단계를 그대로 옮긴 것이다 — 각
> 항목의 "다음 사람이 할 일"은 **새로 만들기(Create)가 아니라 대부분 검색해서
> 연결(Lookup)** 이라는 걸 눈여겨보면 좋다.

### Step 1 — A(사라) → B(혜준)

**내가(A) 하는 일**: Person Account 11명(이하은 외 10명)에 `Gender__c`/`Birthdate`/`Favorite_Player__c` 입력 → "10~30대 여성 팬 Fan Insight" Report 생성.

**다음 사람(B)이 하는 일**: 이 Report를 열어보고, Lead를 **새로 만든다**(A의 Report는 Lookup 대상이 아니라 "근거 자료"이기 때문). Lead.Company = `d'Alba(달바)`, Lead.Description에 `[SCN-B2B-001] 10~30대 여성 팬층 × 뷰티/라이프스타일 관심 신호(SNS 반응률) 기반 Fit 가설`을 적어서, 나중에 아무나 이 Lead를 열어봐도 "왜 이 Lead가 생겼는지" A의 근거를 바로 알 수 있게 한다.

### Step 2 — B(혜준) → C(아론)

**내가(B) 하는 일**: Lead(d'Alba(달바)) 정보를 다 채운 뒤, **Convert 버튼**을 누른다. 직접 Account를 만들지 않는다.

**다음 사람(C)이 하는 일**: Convert로 자동 생성된 Account/Contact를 **찾아서** 부족한 표준 필드(Industry, Website 등)를 채운다. **여기서 새 Account를 또 만들면 안 된다** — Convert가 만든 그 Account가 유일한 d'Alba(달바) 레코드여야 한다.

### Step 3 — C(아론) → D(은영)

**내가(C) 하는 일**: Account(d'Alba(달바))의 Industry, Description 등을 채우고, Contact(김하나)에 Title/Email을 채운다.

**다음 사람(D)이 하는 일**: Opportunity를 새로 만들 때, `Account Name` 항목에 "d'Alba"라고 **검색해서** C가 만든 Account를 선택한다(직접 타이핑 금지 — 오타 나면 새 Account가 생겨버림). Opportunity.`OpportunityContactRole`에도 C의 Contact(김하나)를 검색해서 연결한다.

### Step 4 — D(은영) → E(승우)

**내가(D) 하는 일**: Opportunity(d'Alba(달바) × Cloud Alpacas — Advertising Sponsorship) 생성, StageName/Amount/CloseDate 입력.

**다음 사람(E)이 하는 일**: 세 가지를 D의 Opportunity 하나에 전부 연결한다.
1. **Product Line Item** — Opportunity 하위 Related List에서 Product2(d'Alba 전광판 광고+Brand Day 패키지)를 검색해서 추가
2. **Quote** — 같은 Opportunity를 `OpportunityId`로 지정해 Quote 생성, QuoteLineItem에 같은 Product2를 다시 검색해서 추가(1번과 동일 Product2 재사용, 새로 만들지 않음)
3. **Campaign** — Campaign 생성 후, D의 Opportunity를 `Primary Campaign Source`로 지정

### Step 5 — E(승우) → A(사라) *(마지막, 처음 담당자에게 돌아옴)*

**내가(E) 하는 일**: Campaign(d'Alba Sponsorship Campaign) 완성.

**다음 사람(A)이 하는 일**: E의 Campaign에 CampaignMember로 **자신의 11명**(이하은 외 10명)을 추가한다 — 새 대상을 찾지 않고 Step 1에서 자기가 이미 만든 그 11명을 그대로 재사용한다. 이후 Pipeline/Revenue Dashboard에서 전체 체인이 실제로 연결됐는지 마지막 검증을 한다(계약 이후 Performance 분석은 Future Scope, `00_STORY.md` §8.4).

---

## 4. 작업 순서 (의존성 순서 — 이 순서를 벗어나면 안 됨)

```
A. 사라 (Fan Insight)
   ↓ (근거로 참고, Lookup 아님)
B. 혜준 (Lead 생성)
   ↓ (Lead Convert)
C. 아론 (Account + Contact 생성)
   ↓ (Account Lookup)
D. 은영 (Opportunity 생성)
   ↓ (Opportunity Lookup)
E. 승우 (Product/Quote/Campaign 생성)
   ↓
A. 사라 (Campaign Member로 11명 연결, Pipeline/Revenue Dashboard 확인)
   ↓
Integration QA (전체 5명)
```

**중요**: A는 시작(Fan Insight)과 끝(Campaign Member 연결·Performance 확인)에 두 번 등장한다 — Fan 360이 B2B 시나리오의 출발점이자 성과 검증 지점이기 때문이다(`00_STORY.md` Business Goal과 동일한 구조).

---

## 5. End-to-End 검증 체크리스트

월요일 개별 작업 후, 화요일 Integration 전에 아래를 순서대로 확인한다.

- [ ] A의 11명 Person Account가 실제로 존재하고 `Gender__c`/`Birthdate`/`Favorite_Player__c`가 채워져 있는가
- [ ] B의 Lead(d'Alba(달바)) Description에 `[SCN-B2B-001]`이 포함되어 있는가
- [ ] B의 Lead가 Convert되어 C의 Account/Contact가 **새로 생성이 아니라 Convert 결과로** 존재하는가
- [ ] D의 Opportunity.`AccountId`가 C의 Account(d'Alba(달바))를 정확히 가리키는가
- [ ] E의 Product가 D의 Opportunity에 Line Item으로 붙어 있는가
- [ ] E의 Campaign이 D의 Opportunity를 `Primary Campaign Source`로 연결하고 있는가
- [ ] E의 CampaignMember 11명이 A의 11명과 정확히 일치하는가
- [ ] 전체 레코드의 Description/이름에 `[SCN-B2B-001]` (또는 팀이 정한 최종 Scenario ID)이 일관되게 들어가 있는가

---

## 6. 공유 Object 변경 제안 로그

> B/C/D/E가 작업 중 Person Account, Season__c, Game__c 등 **공유 Object**에 필드 추가가
> 필요하다고 판단되면, 아래 표에 먼저 기록하고 팀 합의 후에만 반영한다.

| 제안자 | Object | 제안 Field | 이유 | 사용 Feature | 영향 범위 | 상태 |
|---|---|---|---|---|---|---|
| *(예시)* | *(예시)* | *(예시)* | *(예시)* | *(예시)* | *(예시)* | ⭐️ TBD |
