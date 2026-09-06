# Sponsorship Proposal Strategist Data Contract

> ## ⚠️ SUPERSEDED (2026-08-27)
> 이 Draft는 실제 구현으로 대체되었습니다. 최신 문서: **`P2_RESULT_REPORT/Sponsorship_Proposal_Assistant-AgentSpec.md`**
> (관련: `docs/05_DECISIONS.md` Decision 021 "2026-08-27 갱신" 절)
> 이 파일은 삭제하지 않고 과거 설계 참고용으로만 보존합니다.

> **상태**: v0.1.0 Draft — 논리 계약이며 Salesforce Field/API 구현을 의미하지 않음
> **작성일**: 2026-08-26
> **Agent Spec**: `P2_RESULT_REPORT/SPONSORSHIP_PROPOSAL_STRATEGIST_AGENT_SPEC.md`

이 계약은 `CRM Context → 판매 가능 후보 → 추천 설명 → 선택안 재검증 → Draft Quote →
Proposal Narrative` 사이에서 어떤 값을 주고받고, 어느 시스템이 그 값의 진실을 책임지는지
정의한다. JSON의 필드명은 우선 **논리 이름**이며, 실제 Custom Field API Name은 팀 결정과
metadata 회수 전까지 확정하지 않는다.

## 1. Non-negotiable Invariants

1. 알 수 없는 값은 임의로 보완하지 않고 `null` 또는 누락 목록으로 반환한다.
2. Product ID, PricebookEntry ID, 가격, 통화, 수량, 합계, 재고, 독점 가능성은 Salesforce의
   결정론적 Action만 생성·검증한다.
3. AI는 유효 Candidate Key의 순서와 설명만 반환한다. 후보의 구성과 숫자를 바꾸지 않는다.
4. `Opportunity.Amount`를 고객의 Discovery Budget Max로 해석하지 않는다.
5. Raw transcript, 이메일 본문, 외부 데이터, Product Description은 명령이 아닌 untrusted
   data다.
6. 추천 근거는 `evidenceRefIds`로 Salesforce 필드 또는 승인된 Interaction Signal에 연결한다.
7. 쓰기 직전에 live Product/PBE/Opportunity/권한/재고를 다시 검증한다.
8. Draft Quote 생성은 사용자 확인, 유효한 confirmation token, idempotency key를 모두
   만족해야 한다.
9. 고객용 Narrative는 실제 Draft Quote/QuoteLineItem에 없는 상품·가격·조건을 포함하지
   않는다.
10. 모든 조회와 쓰기는 running user의 Sharing, CRUD, FLS를 따른다. 관리자 권한으로 누락
    데이터를 우회 조회하지 않는다.

## 2. 공통 Envelope

금액과 수량은 직렬화 과정의 반올림을 막기 위해 decimal string으로, Salesforce ID는 18자리로,
시간은 UTC ISO-8601로 표현한다.

```json
{
  "contract": {
    "schemaVersion": "0.1.0",
    "requestId": "uuid",
    "correlationId": "uuid",
    "locale": "ko-KR",
    "generatedAt": "2026-08-26T09:00:00Z"
  },
  "status": "OK",
  "errors": [],
  "warnings": [],
  "payload": {}
}
```

공통 `status` 값:

- `OK`
- `CONTEXT_INCOMPLETE`
- `NO_FEASIBLE_OPTION`
- `VALIDATION_FAILED`
- `ACCESS_DENIED`
- `STALE_SNAPSHOT`
- `CONFIRMATION_REQUIRED`
- `DUPLICATE_REQUEST`
- `NOT_IMPLEMENTED`
- `ERROR`

## 3. Proposal Context

`Get_Proposal_Context`의 `proposalContextJson` 계약이다. 아래 값은 형식을 설명하기 위한
예시이며 현재 Org에 같은 Custom Field가 존재한다는 뜻이 아니다.

```json
{
  "schemaVersion": "0.1.0",
  "asOf": "2026-08-26T08:59:30Z",
  "opportunity": {
    "id": "006000000000000AAA",
    "lastModifiedAt": "2026-08-26T08:00:00Z",
    "accountId": "001000000000000AAA",
    "accountName": "d'Alba",
    "industry": "Cosmetics / Beauty",
    "stage": "Proposal/Quote",
    "amount": { "value": "300000000", "currency": "KRW" },
    "closeDate": "2027-03-01",
    "partnerTier": "Gold",
    "pricebookId": "01s000000000000AAA",
    "currency": "KRW"
  },
  "discovery": {
    "objectives": ["20-30대 여성 팬 대상 브랜드 인지도 확대"],
    "targetSegments": ["20-30대 여성 팬"],
    "primaryKpi": "BRAND_AWARENESS",
    "secondaryKpis": ["SOCIAL_ENGAGEMENT"],
    "budget": {
      "min": "200000000",
      "max": "300000000",
      "currency": "KRW"
    },
    "preferredChannels": ["SOCIAL", "STADIUM"],
    "interestedProductCodes": [],
    "requiredProductCodes": [],
    "excludedProductCodes": [],
    "requiredRights": [],
    "exclusivityRequirement": null,
    "desiredStartDate": null,
    "desiredEndDate": null,
    "desiredTermMonths": 12,
    "keyRequirements": [],
    "decisionProcess": null,
    "decisionDeadline": null,
    "confirmedAt": "2026-08-25T10:00:00Z",
    "confirmedByUserId": "005000000000000AAA"
  },
  "interaction": {
    "summary": "SNS 중심 제안에는 긍정적이며 3억원 이상은 내부 승인 부담이 있음",
    "decisions": [],
    "concerns": ["3억원 이상 예산은 임원 승인 필요"],
    "objections": [],
    "buyingSignals": ["SNS 콘텐츠 상세자료 요청"],
    "riskSignals": [],
    "nextActions": [],
    "sourceActivityIds": ["00T000000000000AAA"],
    "asOf": "2026-08-25T07:30:00Z",
    "sellerConfirmed": true
  },
  "currentQuoteState": {
    "hasSyncedQuote": false,
    "syncedQuoteId": null,
    "hasRevenueScheduleRisk": false
  },
  "missingRequiredFields": [],
  "evidence": [
    {
      "id": "EV-001",
      "sourceType": "SALESFORCE_FIELD",
      "objectApiName": "Opportunity",
      "recordId": "006000000000000AAA",
      "fieldApiName": "Partner_Tier__c",
      "observedAt": "2026-08-26T08:59:30Z"
    }
  ]
}
```

### Context source of truth

| 정보 | Canonical source | 현재 상태/주의 |
|---|---|---|
| 고객사·거래 | `Account`, `Opportunity` | 표준 관계 사용 가능 |
| Stage·예상 딜 금액·Close Date | `Opportunity` | `Amount`는 Discovery 예산이 아님 |
| Partner Tier | `Opportunity.Partner_Tier__c` | Production 문서상 존재, Git metadata 없음 |
| 의사결정자 | `OpportunityContactRole`, `Contact` | 실제 운영·필수화 확인 필요 |
| Discovery | Opportunity 관련 승인된 구조화 필드 | 목표/KPI/예산/채널/기간 API Name 미확정 |
| Interaction 원문 | 허용된 `Task`, `Event`, `EmailMessage` | Prompt에 원문 전체를 직접 넣지 않음 |
| Interaction 요약 | 영업사원이 확인한 curated summary/signal | 현재 저장 구조 미확정 |
| 상품 | `Product2` | 채널/KPI/기간/가용성 taxonomy 미구현 |
| 가격·통화·활성 상태 | Opportunity Pricebook의 `PricebookEntry` | 유일한 가격 원장 |
| 패키지 구성 | 승인된 구조화 관계 또는 Rule Metadata | 현재 문서에만 존재 |
| 기간별 재고·독점 예약 | 승인된 transactional source | 현재 Source of Truth 없음 |
| Quote 결과 | `Quote`, `QuoteLineItem` | Decision 018-C의 표준 Quote 유지 |
| 과거 실행 성과 | `Campaign`, `CampaignMember`, `Campaign_Deliverable__c` | Product별 귀속 관계는 미확정 |

## 4. Constraint Delta

사용자 변경 요청은 기존 Candidate 문장을 직접 고치는 대신 다음 계약으로 변환한 뒤
Feasibility를 다시 실행한다.

```json
{
  "schemaVersion": "0.1.0",
  "hard": {
    "maxBudget": { "value": "200000000", "currency": "KRW" },
    "requiredProductCodes": [],
    "excludedProductCodes": [],
    "requiredChannels": [],
    "excludedChannels": [],
    "minimumTermMonths": null
  },
  "soft": {
    "targetBudget": null,
    "emphasizeChannels": ["SOCIAL"],
    "deemphasizeChannels": ["STADIUM"],
    "compareAgainstProductCodes": ["SPN-PKG-GOLD"],
    "rankingProfile": "SOCIAL_FIRST"
  },
  "sourceUtterance": "2억원 이하로, SNS를 더 중요하게 구성해줘",
  "confirmedByUser": true
}
```

해석 규칙:

| 사용자 표현 | 계약 해석 |
|---|---|
| “2억원 이하” | `hard.maxBudget=200000000` |
| “2억원 정도” | `soft.targetBudget=200000000`; 허용 범위가 필요하면 확인 |
| “SNS를 더 중요하게” | `soft.emphasizeChannels=[SOCIAL]` |
| “오프라인은 제외” | `hard.excludedChannels`에 해당 taxonomy 추가 |
| “Gold와 비교” | Gold를 비교 대상으로 추가하되 Feasibility는 별도 검증 |

사용자 입력은 가격 원장, 승인 한도, 재고, 독점 정책을 override할 수 없다.

## 5. Readiness Result

```json
{
  "schemaVersion": "0.1.0",
  "isReady": false,
  "missingRequiredFields": [
    { "logicalName": "discovery.budget.max", "label": "최대 예산" }
  ],
  "blockingReasons": [
    { "code": "MISSING_HARD_BUDGET", "message": "추천 전에 최대 예산이 필요합니다." }
  ],
  "warnings": [
    { "code": "STALE_INTERACTION_SUMMARY", "message": "최근 고객 반응이 90일보다 오래되었습니다." }
  ]
}
```

초기 Blocking 항목:

- Opportunity, Account, Stage, Pricebook, Currency
- Business Objective와 Primary KPI
- Hard Budget Max
- Target Segment 또는 Priority Channel
- 계약 기간/시점
- Active Sponsorship Product와 PBE
- 실행 사용자의 필수 조회 권한

Interaction summary, Decision Process, 세부 요구사항은 데이터 품질 경고로 시작할 수 있으나,
해당 값이 추천 근거로 사용되면 확인된 evidence가 필요하다.

## 6. Feasible Candidate Set

`Build_Feasible_Candidates`는 Hard constraint를 통과한 구성만 반환한다.

```json
{
  "schemaVersion": "0.1.0",
  "candidateSetId": "CSET-uuid",
  "opportunityId": "006000000000000AAA",
  "generatedAt": "2026-08-26T08:59:40Z",
  "ruleVersion": "proposal-rules-0.1.0",
  "pricebookSnapshotKey": "sha256:example",
  "options": [
    {
      "optionId": "OPT-001",
      "optionType": "CUSTOM_PACKAGE",
      "label": "SNS Engagement 중심 Custom Package",
      "lines": [
        {
          "productId": "01t000000000000AAA",
          "pricebookEntryId": "01u000000000000AAA",
          "productCode": "SPN-SNS-CONTENT",
          "name": "공식 SNS 브랜디드 콘텐츠",
          "quantity": "1",
          "listUnitPrice": "100000000",
          "lineTotal": "100000000",
          "currency": "KRW"
        },
        {
          "productId": "01t000000000001AAA",
          "pricebookEntryId": "01u000000000001AAA",
          "productCode": "SPN-COLLAB-GOODS",
          "name": "콜라보 굿즈 공동기획",
          "quantity": "1",
          "listUnitPrice": "80000000",
          "lineTotal": "80000000",
          "currency": "KRW"
        }
      ],
      "pricing": {
        "listTotal": "180000000",
        "validatedTotal": "180000000",
        "discountPercent": "0",
        "currency": "KRW",
        "source": "LIVE_PRICEBOOK_ENTRIES"
      },
      "deterministicFitFeatures": {
        "objectiveFit": 90,
        "kpiFit": 92,
        "channelFit": 95,
        "budgetFit": 88,
        "interactionFit": 85,
        "executionComplexity": 20
      },
      "confidence": {
        "score": 78,
        "missingData": ["decisionProcess"]
      },
      "hardConstraintStatus": "PASS",
      "hardChecks": [
        { "code": "ACTIVE_PRICEBOOK_ENTRY", "passed": true },
        { "code": "CURRENCY_MATCH", "passed": true },
        { "code": "WITHIN_HARD_BUDGET", "passed": true }
      ],
      "evidenceRefIds": ["EV-PRODUCT-001", "EV-PRICE-001"]
    }
  ]
}
```

초기 Hard check:

- Product2와 PricebookEntry Active
- Opportunity Pricebook·Currency 일치
- Hard Budget Max 이하
- 계약 기간과 최소 판매 기간 일치
- 희소 자산 재고 존재
- 업종 독점 충돌 없음
- Product 필수·배타 조합 통과
- Bundle 구성요소 중복 청구 없음
- 가격 하한·할인 정책 준수
- 실행 사용자 권한 존재
- Quote Sync·Revenue Schedule 제약 통과

표준 Blocking reason code:

- `INACTIVE_PRODUCT`
- `INACTIVE_PRICEBOOK_ENTRY`
- `PRICEBOOK_MISMATCH`
- `CURRENCY_MISMATCH`
- `OVER_HARD_BUDGET`
- `TERM_MISMATCH`
- `INVENTORY_UNAVAILABLE`
- `EXCLUSIVITY_CONFLICT`
- `INCOMPATIBLE_PRODUCT_COMBINATION`
- `DUPLICATE_BUNDLE_COMPONENT`
- `MISSING_AUTHORITATIVE_PRICE`
- `MISSING_REQUIRED_PRODUCT_DATA`
- `ACCESS_DENIED`

## 7. Ranked Recommendation

AI 출력은 Candidate Key와 설명만 포함한다. Product/PBE/가격 배열을 다시 생성하지 않는다.

```json
{
  "schemaVersion": "0.1.0",
  "candidateSetId": "CSET-uuid",
  "rankingPolicyVersion": "proposal-ranking-0.1.0",
  "rankedOptions": [
    {
      "optionId": "OPT-001",
      "rank": 1,
      "role": "RECOMMENDED",
      "fitScore": 88,
      "confidenceScore": 78,
      "matchedNeeds": ["SOCIAL_ENGAGEMENT", "BUDGET_MAX"],
      "unmetNeeds": [],
      "recommendationReasons": [
        {
          "text": "SNS Engagement 우선 요구와 2억원 상한을 함께 충족합니다.",
          "evidenceRefIds": ["EV-DISCOVERY-KPI", "EV-BUDGET", "EV-PRODUCT-001"]
        }
      ],
      "concerns": [],
      "tradeoffs": ["경기장 반복 노출 비중은 낮습니다."],
      "assumptions": []
    }
  ],
  "requiresHumanReview": false
}
```

`role` 값:

- `RECOMMENDED`
- `BUDGET_SAFE`
- `STRATEGIC_STRETCH` — Hard budget을 넘지 않거나 사용자가 budget을 soft로 지정했을
  때만 허용

Fit Score는 니즈 적합도다. `Partner_Tier__c`, Fan Fit Score, Lead Score, 계약 성사
확률을 대신하거나 변경하지 않는다. 과거 Product 성과 근거가 없으면 예상 ROI, 도달량,
전환 수치를 만들지 않는다.

## 8. Selected Candidate Validation

Validation은 AI가 아니라 Apex/Flow가 live data를 재조회해 수행한다.

```json
{
  "schemaVersion": "0.1.0",
  "validationId": "VAL-uuid",
  "candidateSetId": "CSET-uuid",
  "selectedOptionId": "OPT-001",
  "validatorVersion": "proposal-validator-0.1.0",
  "validatedAt": "2026-08-26T09:01:00Z",
  "valid": true,
  "checks": [
    { "code": "OPPORTUNITY_PRICEBOOK_MATCH", "passed": true, "blocking": true },
    { "code": "ALL_PRODUCTS_ACTIVE", "passed": true, "blocking": true },
    { "code": "ALL_PRICEBOOK_ENTRIES_ACTIVE", "passed": true, "blocking": true },
    { "code": "TOTAL_WITHIN_BUDGET", "passed": true, "blocking": true },
    { "code": "NO_EXCLUSIVITY_CONFLICT", "passed": true, "blocking": true },
    { "code": "USER_CAN_CREATE_QUOTE", "passed": true, "blocking": true }
  ],
  "resolvedPricing": {
    "total": "180000000",
    "currency": "KRW",
    "source": "LIVE_PRICEBOOK_ENTRIES"
  },
  "confirmation": {
    "token": "opaque-single-use-token",
    "expiresAt": "2026-08-26T09:06:00Z"
  },
  "errors": [],
  "warnings": []
}
```

추가 검사:

- Opportunity Stage·Pricebook·Currency가 Context 이후 바뀌지 않았는지
- Product/PBE/가격과 Rule Version이 여전히 유효한지
- 기존 Sync Quote 또는 Revenue Schedule과 충돌하는지
- 할인 임계값과 승인 필요 여부
- 계약 기간과 Revenue Schedule 정합성
- 동일 업종 독점 자산의 판매·예약 충돌
- 같은 요청으로 이미 Quote가 생성됐는지

## 9. Draft Quote Write Intent와 Result

Validation 성공은 DML 승인이 아니다. 먼저 사용자에게 다음 `writeIntent`를 보여준다.

```json
{
  "writeIntentId": "WRITE-uuid",
  "status": "PENDING_SELLER_CONFIRMATION",
  "validationId": "VAL-uuid",
  "opportunityId": "006000000000000AAA",
  "selectedOptionId": "OPT-001",
  "quoteName": "d'Alba Sponsorship Proposal v1",
  "currency": "KRW",
  "expirationDate": "2026-09-30",
  "validatedTotal": "180000000",
  "lines": [
    {
      "pricebookEntryId": "01u000000000000AAA",
      "productCode": "SPN-SNS-CONTENT",
      "quantity": "1",
      "validatedUnitPrice": "100000000",
      "lineTotal": "100000000"
    }
  ],
  "sellerConfirmation": {
    "required": true,
    "confirmedByUserId": null,
    "confirmedAt": null
  }
}
```

확인·재검증 후 성공 결과:

```json
{
  "status": "CREATED",
  "idempotencyKey": "opaque-key",
  "quoteId": "0Q0000000000000AAA",
  "quoteNumber": "000000123",
  "quoteLineItemIds": ["0QL000000000000AAA"],
  "createdAt": "2026-08-26T09:05:00Z",
  "synced": false,
  "approvalSubmitted": false,
  "documentSent": false
}
```

`idempotencyKey` 재사용은 새 Quote를 만들지 않고 최초 결과를 반환해야 한다.

## 10. Proposal Narrative

내부 전략과 고객 전달 문구를 분리한다. 내부 Concern이 고객용 초안에 섞이면 안 된다.

```json
{
  "schemaVersion": "0.1.0",
  "quoteId": "0Q0000000000000AAA",
  "sourceQuoteLastModifiedAt": "2026-08-26T09:05:00Z",
  "locale": "ko-KR",
  "internalStrategy": {
    "recommendationSummary": "SNS 중심 패키지를 우선 제안",
    "potentialConcerns": [],
    "alternativeStrategy": null,
    "evidenceRefIds": []
  },
  "customerFacingProposal": {
    "partnershipObjective": "",
    "recommendedSponsorship": "",
    "expectedValueBullets": [],
    "packageDetails": [],
    "commercialSummary": {
      "validatedTotal": "180000000",
      "currency": "KRW"
    },
    "nextStep": ""
  },
  "prohibitedClaimsRemoved": [
    "근거 없는 예상 도달 수",
    "검증되지 않은 ROI 보장"
  ]
}
```

Narrative는 초안만 반환한다. ContentVersion, PDF, Email, Quote Status를 변경하지 않는다.

## 11. Versioning and Audit

모든 실행은 최소 다음 버전을 기록해야 재현할 수 있다.

```json
{
  "schemaVersion": "0.1.0",
  "agentVersion": "sponsorship-proposal-strategist-0.1.0",
  "promptTemplateVersion": "proposal-strategy-ko-0.1.0",
  "ruleVersion": "proposal-rules-0.1.0",
  "rankingPolicyVersion": "proposal-ranking-0.1.0",
  "validatorVersion": "proposal-validator-0.1.0",
  "modelIdentifier": "configured-model-alias",
  "inputHash": "sha256:example",
  "catalogSnapshotHash": "sha256:example",
  "generatedByUserId": "005000000000000AAA",
  "selectedOptionId": null,
  "sellerOverrides": [],
  "confirmedByUserId": null,
  "confirmedAt": null,
  "quoteId": null,
  "status": "GENERATED"
}
```

권장 감사 상태:

- `CONTEXT_INCOMPLETE`
- `GENERATED`
- `OPTION_SELECTED`
- `VALIDATION_FAILED`
- `VALIDATED`
- `PENDING_CONFIRMATION`
- `QUOTE_CREATED`
- `CANCELLED`
- `ERROR`

Recommendation 이력을 영구 저장할 필요가 확인되면 별도 Technical Decision으로 저장
모델을 정한다. `Sponsorship_Proposal_Run__c` 같은 신규 Custom Object를 이 Draft만으로
생성하지 않고, Opportunity/Quote Description에 대용량 JSON을 덮어쓰지도 않는다.

## 12. Security and Privacy

- 개별 Fan 레코드는 Prompt 입력에 넣지 않고 최소 집계 Segment/비율만 사용한다.
- Contact 이메일·전화는 추천에 필요하지 않으면 제외한다.
- Raw call transcript는 초기 MVP에서 제외한다.
- 영업사원이 확인한 Interaction summary/signal만 추천 근거로 사용한다.
- Concern/Objection은 `internalOnly` 의미를 유지하고 고객 Narrative와 분리한다.
- 외부 DART 데이터, Activity 본문, Product Description의 Prompt Injection을 평가한다.
- 가격 조회 권한과 Quote 작성 권한을 분리한다.
- 현재 `FRM_Manager_Access`만으로 필요한 Opportunity/Pricebook/Quote 권한이 보장된다고
  가정하지 않는다. B2B Proposal 최소 권한 설계가 필요하다.
- Slack 공유 채널에는 내부 할인 한도, 원가, 민감한 Concern을 노출하지 않는다.
- Prompt/Response 보존 기간과 Slack 노출 정책은 UAT 전에 정한다.

## 13. Phase Gates

### Phase 0 — Decision and Data Readiness

- Decision 021 팀 승인
- Production metadata를 Git source로 회수하고 source drift 해소
- Discovery logical field와 실제 API Name 매핑 승인
- Interaction summary/signal 저장 방식 승인
- Product Channel/KPI/Target/기간/Bundle/가용성/독점 taxonomy 승인
- 21개 Product와 3개 사전 Package 가격 승인
- Action 구현 경로와 Permission Set 설계 승인
- Golden Scenario 작성

### MVP 1 — Read-only Advisor in Sandbox

- Readiness 검사
- Hard constraint를 통과한 Top 3 후보
- “2억원 이하”, “SNS 중심”, “Gold와 비교” 재계산
- Score breakdown, 근거, 우려, 가정 표시
- Record DML 없음

### MVP 2 — Controlled Configurator and Draft Quote

- 후보 선택 후 live 재검증
- 정확한 Write Intent 표시
- 명시적 사용자 확인
- idempotent Standard Draft Quote 생성
- Sync, Approval, PDF, 발송 없음

### MVP 3 — Proposal Narrative and UAT

- 검증된 Draft Quote 기반 Narrative
- 한국어/영어, 권한, 예산, Currency, 비활성 상품, 누락 데이터, Prompt Injection,
  confirmation cancel, 중복 쓰기 평가
- Business Reviewer 승인 후에만 Production Release Decision 검토

가장 먼저 닫아야 할 구현 Gate는 다음 네 가지다.

- `SOURCE_DRIFT_RESOLVED`
- `DISCOVERY_CONTRACT_APPROVED`
- `CATALOG_ATTRIBUTES_COMPLETE`
- `PERMISSION_CHECK_PASSED`

하나라도 실패하면 Agent는 추천을 생성하지 않고 부족한 정보와 다음 조치를 안내한다.
