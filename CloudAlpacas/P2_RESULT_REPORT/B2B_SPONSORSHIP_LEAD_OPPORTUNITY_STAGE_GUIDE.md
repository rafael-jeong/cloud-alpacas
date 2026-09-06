# B2B 스폰서십 Lead Status · Opportunity Stage 가이드

> Cloud Alpacas의 B2B 스폰서십 영업에서 Lead와 Opportunity 상태를 일관되게 사용하기 위한 운영 가이드입니다.

| 항목 | 내용 |
| --- | --- |
| 기준일 | 2026-08-24 |
| 대상 Org | CloudAlpacas Production |
| 대상 업무 | B2B Sponsorship Sales |
| 확인 기준 | Production Org의 활성 Lead Process 및 Opportunity Stage |

## 1. Lead와 Opportunity의 역할 차이

- **Lead**: 아직 정식 거래처로 받아들일지 검토 중인 잠재 스폰서 기업 또는 담당자
- **Opportunity**: 예산, 수요, 담당자 등이 확인되어 구체적인 계약 가능성을 관리하는 영업 건
- Salesforce에서는 Lead는 `Stage`가 아니라 **Status**, Opportunity는 **Stage**라고 부른다.

```text
Lead
New → Working → Qualified → Converted
                                ↓
Opportunity
Qualification → Discovery → Proposal/Quote
→ Negotiation → Contracting
→ Closed Won 또는 Closed Lost
```

## 2. Lead Status

B2B 스폰서십이 사용하는 `Sales Lead` 프로세스에는 아래 네 개의 Status가 포함되어 있다.

### 2.1 New

- 새로 유입된 잠재 스폰서 후보
- 아직 담당자가 본격적으로 검토하거나 접촉하지 않은 상태
- 신규 Lead 생성 시 기본값

다음 단계로 이동하는 기준:

- 담당자가 배정됨
- 기업 및 담당자 기본정보 확인을 시작함
- 첫 연락 또는 사전 조사를 시작함

### 2.2 Working

- 담당자가 기업 조사, 연락, 미팅 등을 진행하는 상태
- 브랜드와 Cloud Alpacas 팬층의 적합성을 확인하는 단계
- 예산, 의사결정자, 니즈, 도입 시기를 파악함

다음 단계로 이동하는 기준:

- 실제 스폰서십 관심 또는 구매 가능성이 확인됨
- 담당자 및 의사결정 구조가 확인됨
- 구체적인 제안을 검토할 가치가 있음

### 2.3 Qualified

- 실제 스폰서십 제안 대상으로 적합하다고 판단된 상태
- Account, Contact, Opportunity로 변환할 준비가 완료됨
- 아직 Salesforce Lead 변환 자체가 완료된 상태는 아님

다음 단계로 이동하는 기준:

- 기업 중복 여부 확인 완료
- Account와 Contact 생성 또는 연결 기준 확인 완료
- 구체적인 Sponsorship Opportunity 생성에 필요한 정보 확보

### 2.4 Converted

- Lead를 Account, Contact 및 필요한 경우 Opportunity로 변환한 최종 상태
- Lead 단계의 영업 관리는 종료됨
- 이후 계약 진행은 Opportunity Stage에서 관리함

### 2.5 스폰서십 예시

```text
New
d'Alba 담당자 또는 스폰서 후보가 새로 등록됨

→ Working
기업 조사, 담당자 접촉, 팬 타깃과 브랜드 적합성 확인

→ Qualified
예산과 관심 상품이 확인되어 구체적인 제안이 가능함

→ Converted
d'Alba Account·Contact 및 Sponsorship Opportunity로 전환
```

### 2.6 다른 Lead Status와의 구분

Org 전체에는 다음과 같은 추가 Lead Status도 존재한다.

- `Unqualified`
- `Draft`
- `Submitted`
- `Approved`
- `Pending`
- `Rejected`
- `Candidate`

하지만 이 값들은 현재 B2B 스폰서십이 사용하는 `Sales Lead` 프로세스에는 포함되지 않는다. Deal Registration, Partner Application 등 다른 Lead Process의 상태와 혼용하지 않는다.

## 3. Opportunity Stage

현재 CloudAlpacas Org에서 활성화된 Opportunity Stage는 아래 일곱 단계다.

| Opportunity Stage | 기본 확률 | Forecast Category | 스폰서십에서의 의미 |
| --- | ---: | --- | --- |
| `Qualification` | 20% | Pipeline | 실제 영업기회인지 기본 자격을 검증 |
| `Discovery` | 35% | Best Case | 브랜드 목표, 타깃 팬, 예산, KPI와 희망 상품을 구체화 |
| `Proposal/Quote` | 75% | Best Case | Product와 가격을 확정하고 공식 Quote를 제안 |
| `Negotiation` | 90% | Commit | 가격, 권리, 노출 범위, 지급조건과 실행 의무를 협상 |
| `Contracting` | 95% | Commit | 주요 조건 합의 후 계약서 검토·결재·서명을 진행 |
| `Closed Won` | 100% | Closed | 계약 체결 완료 후 Campaign 실행으로 인계 |
| `Closed Lost` | 0% | Omitted | 계약이 성사되지 않아 사유를 기록하고 종료 |

> 기본 확률은 Salesforce Forecast를 위한 기준값이며, 실제 계약 성공 가능성을 자동으로 보장하는 점수가 아니다.

### 3.1 Qualification

- 스폰서 후보 기업과 담당자가 식별됨
- 브랜드와 팬 타깃 간 기본 적합성을 검토함
- 대략적인 예산, 관심도, 추진 시기를 확인함
- 상품 구성이나 Quote는 아직 확정하지 않음

다음 단계로 이동하는 기준:

- 실제 예산 또는 구매 의향이 있음
- 의사결정자 또는 실무 담당자와 접촉 가능함
- 구체적인 요구사항을 논의할 가치가 있음

### 3.2 Discovery

- 브랜드의 캠페인 목표를 파악함
- 원하는 팬 세그먼트와 노출 채널을 확인함
- KPI, 일정, 예산 범위, 독점 조건을 조사함
- 제공 가능한 스폰서십 상품과 비교함

다음 단계로 이동하는 기준:

- 제안할 Product 조합이 결정됨
- 가격과 실행 범위를 산정할 수 있음
- 고객에게 공식 제안서를 전달할 준비가 됨

### 3.3 Proposal/Quote

- Opportunity Product가 연결됨
- Quote와 Quote Line Item이 생성됨
- 가격, 수량, 기간, 패키지 구성이 공식 제안됨
- 고객이 제안 내용을 검토 중임

다음 단계로 이동하는 기준:

- 고객이 협상 의사를 표시함
- 주요 반대사항 또는 수정 요청이 확인됨

### 3.4 Negotiation

다음과 같은 주요 거래 조건을 협상하는 단계다.

- 가격과 할인
- 계약기간
- 독점권과 경쟁업종 제한
- 광고 위치와 노출 횟수
- Brand Day 및 프로모션 범위
- 결제 조건과 취소 조건

다음 단계로 이동하는 기준:

- 주요 상업 조건에 잠정 합의함
- 남은 작업이 계약서 작성과 내부 승인 중심으로 전환됨

### 3.5 Contracting

- 계약서 작성 및 법무 검토
- 고객사와 구단의 내부 결재
- 최종 Quote와 계약 금액 대조
- 서명권자 확인 및 전자서명 진행

다음 단계로 이동하는 기준:

- 양측 서명 완료
- 계약 효력 발생 조건 충족

### 3.6 Closed Won

- 스폰서십 계약 체결 완료
- 최종 금액과 상품 구성이 확정됨
- Campaign을 활성화하고 실행 단계로 인계함
- Campaign Deliverable, 일정, 담당자 및 증빙 관리를 시작함

### 3.7 Closed Lost

다음과 같은 이유로 계약이 성사되지 않은 상태다.

- 예산 미확보
- 경쟁 구단 또는 다른 광고 채널 선택
- 브랜드 전략 변경
- 가격 또는 독점 조건 불일치
- 의사결정 연기

운영 기준:

- 실패 사유를 구조화해 기록함
- 재접촉 가능 시점 또는 대체 패키지를 기록함
- 향후 Agentforce 추천과 Pipeline 분석에 활용할 수 있도록 데이터를 남김

## 4. 상태 관리 원칙

- Lead Status는 **이 후보를 정식 영업 대상으로 받아들일지** 판단하는 데 사용한다.
- Opportunity Stage는 **구체적인 스폰서십 계약이 어디까지 진행됐는지** 관리하는 데 사용한다.
- Campaign Status는 **계약 후 약속한 스폰서십을 얼마나 실행했는지** 관리하는 데 사용한다.
- 단계 변경 시 단순히 확률만 보고 이동하지 않고, 각 단계의 진입·종료 기준을 충족했는지 확인한다.
- `Closed Lost` 처리 시 실패 사유를 반드시 남겨 향후 재제안과 분석에 활용한다.
- `Closed Won` 이후에는 Opportunity가 아니라 Campaign과 Deliverable을 중심으로 실행 성과를 관리한다.

## 5. 요약

```text
Lead Status
잠재 기업을 정식 영업 대상으로 받아들일지 판단

Opportunity Stage
구체적인 계약의 진행 상태와 예상 매출을 관리

Campaign Status
계약 후 약속한 스폰서십의 실제 실행 상태를 관리
```
