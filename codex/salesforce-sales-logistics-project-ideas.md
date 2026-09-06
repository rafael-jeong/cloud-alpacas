# Salesforce Sales & Logistics Issue Management 프로젝트 발전안

## 분석 대상

- `Salesforce 기반 Sales and Logistics Issue Management System 구축 프로젝트 기획서.docx`
- 기획서의 내용은 분석 자료로만 사용했습니다.

## 핵심 제안

이 프로젝트는 단순한 이슈 등록 시스템보다 **Sales & Logistics Exception Control Tower**로 발전시키는 것이 좋습니다.

핵심 업무 흐름은 다음과 같습니다.

```text
이상 감지 → 자동 분류·배정 → 조치 → 증빙 검증 → 관리자 승인
→ 비용 회수·종결 → 재발 분석
```

## 현재 기획서에서 보완할 부분

현재 기획서는 실제 현업 문제와 사용자가 구체적으로 정의되어 있다는 점이 강점입니다. 구현을 시작하려면 다음 내용을 추가로 정의해야 합니다.

- 이슈 상태와 단계별 진입·종료 조건
- `Hot` 이슈의 정량적 판정 기준과 SLA
- 판매계획의 관리 단위: 고객, 제품, 주차 또는 월
- EDI, 판매실적, 청구 데이터의 원천 시스템
- 증빙의 단순 첨부 여부와 재무 검증 완료 여부의 구분
- 담당자 퇴직·부재 시 재배정 규칙
- 역할별 데이터 및 파일 접근권한
- 성공 여부를 판단할 KPI

특히 “모든 것을 하나의 Object에서 관리한다”는 목표는 **모든 데이터를 한 객체에 넣는 것**이 아니라 **사용자가 하나의 공통 진입점에서 이슈를 관리하는 것**으로 해석하는 편이 좋습니다. 모든 필드를 하나의 객체에 넣으면 유형별 필드와 프로세스가 뒤섞이기 쉽습니다.

## 권장 데이터 구조

현재 문서 기준으로는 고객 서비스 요청보다 내부 운영 예외 관리의 성격이 강하므로 `Operational_Issue__c`를 중심으로 두는 안을 추천합니다. Service Cloud 역량을 강조하려는 경우에는 동일 구조를 표준 `Case`로 구현하는 대안도 검토하고, 선택 근거를 ADR(Architecture Decision Record)로 남길 수 있습니다.

| 구성요소 | 역할 |
|---|---|
| `Operational_Issue__c` | 유형, 심각도, 상태, 담당자, SLA, 원인, 영향 금액을 관리하는 공통 이슈 |
| `Issue_Action__c` | 후속 조치, 담당자, 기한, 결과 및 완료 검증 관리 |
| `Evidence_Item__c` | 필수 증빙 유형, 제출·검증 상태, 검증자 및 파일 연결 |
| `Forecast_Snapshot__c` | 고객·제품·주차별 Plan, EDI, Actual 및 편차 저장 |
| `Customer_Playbook__c` | 고객별 업무 루틴, EDI 방식, 정기 일정 및 백업 담당자 관리 |
| `Cost_Claim__c` | 긴급물류 비용, 청구액, 승인액 및 회수 상태 관리 |
| Custom Metadata | 유형별 임계값, SLA, 배정 규칙 및 필수 증빙 목록 설정 |

단순한 `증빙 있음` 체크박스 대신 `Evidence_Item__c`를 별도로 두는 것이 중요합니다. 파일 한 개가 존재하는 것과 업무에 필요한 서류가 모두 제출되고 검증된 것은 다르기 때문입니다.

## 발전 아이디어

### 1. EDI 및 판매계획 이상 자동 감지

고객·제품·주차별 Snapshot을 저장하고, EDI 수량이나 납기 변화가 고객별 임계값을 넘으면 이슈를 자동 생성합니다.

- 고객별·제품별 허용 편차 설정
- EDI 변경 전후 수량과 납기 저장
- 외부 Event ID를 Unique/External ID로 사용
- 동일 이벤트 재수신 시 Upsert하여 중복 이슈 방지
- 임계값 초과 시 영업·물류 담당자에게 자동 배정

### 2. 심각도와 SLA 자동 산정

다음 요소를 점수화하여 이슈 심각도를 계산할 수 있습니다.

- 납기 지연 가능성
- OEM 생산라인 중단 위험
- 예상 영향 금액
- 고객 에스컬레이션 여부
- 고객 및 제품의 중요도

심각도에 따라 Queue, 담당자, 최초 대응 기한과 해결 기한을 자동 설정합니다. 마감 전 알림과 기한 초과 에스컬레이션도 함께 구성합니다.

### 3. 증빙 기반 상태 전환 통제

상태 모델의 예시는 다음과 같습니다.

```text
New → Triage → In Progress → Awaiting Evidence
→ Manager Review → Resolved → Closed
```

`Manager Review` 단계로 이동하려면 다음 조건이 충족되도록 합니다.

- 모든 필수 Action 완료
- Root Cause 입력 완료
- 유형별 필수 증빙 제출 완료
- 재무 또는 지정 검증자의 증빙 검증 완료

불가피한 예외 처리는 Custom Permission을 가진 관리자만 우회할 수 있게 하고, 우회 사유를 감사 기록으로 남기는 방법도 고려할 수 있습니다.

### 4. Account 기반 인수인계 Cockpit

Account 페이지 또는 Handover Screen Flow에서 신규 담당자가 다음 정보를 한 번에 확인하도록 구성합니다.

- Open Issue
- 연체 및 예정 Action·Task
- 고객별 정기 업무 루틴
- EDI 수신 방식
- 주요 연락처와 에스컬레이션 경로
- 이전 담당자의 미완료 항목

Screen Flow를 통해 선택된 Account, Issue, Action 및 Task를 신규 담당자나 백업 Queue에 일괄 재배정하고, 이전·신규 담당자와 실행일을 기록할 수 있습니다.

### 5. 긴급물류 비용 회수 프로세스

다음 과정을 하나의 추적 가능한 업무 흐름으로 연결합니다.

```text
EDI 변경 → 긴급운송 → 비용 발생 → 증빙 확보
→ 고객 Claim → 승인 → 비용 회수
```

이 기능을 추가하면 프로젝트가 단순 이슈 추적 도구를 넘어 실제 재무적 결과까지 관리하는 시스템으로 발전합니다.

### 6. 관리자 주간 브리핑

Dashboard에는 다음 정보를 표시하는 것이 좋습니다.

- 고객별 Hot/Open 이슈
- SLA 위반 및 Aging
- 반복 Root Cause
- 증빙 누락 건수
- 긴급물류 발생 금액과 회수 금액
- 담당자별 업무 편중
- Forecast WAPE와 Bias

AI는 이 데이터를 기반으로 주간 보고서를 요약하거나 원인 분류를 추천하는 선택 기능으로 사용할 수 있습니다. 담당자 배정, 재무 승인 및 이슈 종결은 규칙 기반 자동화와 사람이 결정하도록 유지하는 것이 적절합니다. Salesforce의 공식 가이드도 결과가 명확한 구조화 업무에는 전통적인 자동화를 우선하도록 안내합니다.

- [Salesforce workflow automation guide](https://architect.salesforce.com/docs/architect/decision-guides/guide/determining-agentic-vs-traditional-workflow-automation.html)

## 권장 구현 방식

- 이슈 등록: Screen Flow
- 자동 배정, Task 생성, 알림 및 상태 처리: Record-Triggered Flow
- 고객별 SLA, 라우팅 및 증빙 정책: Custom Metadata
- 대량 EDI Upsert, 복잡한 편차 계산 및 Business Hours 계산: Invocable Apex
- CSV 업로드 또는 Control Tower 화면: 필요한 경우에만 LWC
- 상태, Owner, Due Date, 금액 및 증빙 검증: Field History 또는 별도 감사 객체
- 자동화 오류: 모든 Flow에 Fault Path를 구성하고 오류·재처리 상태 기록

Salesforce의 현재 아키텍처 가이드도 단순·중간 복잡도에서는 Flow를 중심으로 하고, 대량 처리나 복잡한 데이터 로직만 Apex로 분리하는 방식을 권장합니다.

- [Record-Triggered Automation guide](https://architect.salesforce.com/docs/architect/decision-guides/guide/record-triggered.html)

## 연동 전략

연동 방식은 데이터 변경 빈도와 요구 지연시간에 따라 선택합니다.

| 상황 | 권장 방식 |
|---|---|
| 하루 1회 파일 수신 | Batch 또는 예약 처리 |
| OEM 라인 중단 위험처럼 즉시 대응이 필요한 변경 | Platform Event 또는 Pub/Sub |
| 실제 ANSI X12/EDIFACT 해석 | 미들웨어에서 표준 JSON으로 변환 |
| Salesforce 내부 처리 | 변환된 비즈니스 이벤트를 받아 이슈 생성 및 후속 조치 수행 |

공식 가이드도 변경 빈도가 낮으면 배치 처리를, 근실시간 알림이 필요하면 이벤트 기반 패턴을 고려하도록 안내합니다.

- [Event-Driven Architecture guide](https://architect.salesforce.com/docs/architect/decision-guides/guide/event-driven)

## 보안 및 운영 고려사항

- Sales, Logistics, Finance, Manager, Integration User별 Permission Set 분리
- 재무 비용 및 Claim 필드에 별도 Field-Level Security 적용
- Account와 Issue의 공유 범위 설계
- Salesforce Files의 접근권한과 외부 공유 여부 검증
- 통합용 전용 사용자와 Named Credential 사용
- 상태, 담당자, 기한, 비용 및 증빙 검증 이력 추적
- 영어·스페인어용 Custom Label 및 Picklist 번역 고려
- MXN, USD, KRW를 위한 다중 통화 고려
- 멕시코와 한국의 Business Hours 및 시간대 차이 반영

권한은 최소 권한 원칙을 따르되, 불필요하게 복잡한 공유 구조를 만들지 않도록 해야 합니다.

- [Salesforce Well-Architected: Secure](https://architect.salesforce.com/docs/architect/well-architected/guide/secure)

## 대표 데모 시나리오

가장 설득력 있는 시연 흐름은 다음과 같습니다.

1. OEM A의 EDI 수량이 1,000개에서 650개로 감소한 샘플 데이터를 입력합니다.
2. 임계값을 초과하여 Hot 이슈와 영업·물류 Action이 자동 생성됩니다.
3. 긴급운송비와 피해 Claim을 등록합니다.
4. 운임 Invoice가 없는 상태에서 `Manager Review`로 이동하면 시스템이 차단합니다.
5. 증빙 업로드와 재무 검증 후 관리자 승인 및 종결이 가능합니다.
6. Dashboard의 SLA, 증빙 완성도와 회수 대상 금액이 갱신됩니다.
7. 같은 EDI Event를 다시 전송해도 중복 이슈가 생성되지 않습니다.

이 시나리오 하나로 데이터 모델, Flow, Apex, 멱등성, 파일 검증, 권한 및 리포팅을 모두 보여줄 수 있습니다.

## 권장 개발 순서

### 1단계: MVP

- `Operational_Issue__c`, `Issue_Action__c`, `Evidence_Item__c`
- Issue Record Type 3개
- 이슈 상태 및 단계 전환 통제
- Screen Flow를 통한 이슈 등록
- 자동 배정, Task와 알림 생성
- Account 중심 화면
- Dashboard 1개

### 2단계: 업무 통제 확장

- `Forecast_Snapshot__c`
- `Customer_Playbook__c`
- Account 인수인계 Flow
- SLA와 에스컬레이션
- `Cost_Claim__c`
- 감사 이력 및 자동화 오류 처리

### 3단계: 기술 확장

- Mock EDI REST API 또는 Platform Event
- External ID 기반 멱등성
- Queueable Apex와 오류 재처리
- CSV 업로드 또는 Control Tower LWC
- Apex, Flow 및 LWC 자동 테스트

### 4단계: 선택 기능

- 영어·스페인어 지원
- MXN, USD, KRW 다중 통화
- AI 관리자 주간 요약
- Experience Cloud 기반 외부 증빙 제출

MVP에서는 다음 범위를 제외하는 것이 좋습니다.

- 실제 OEM EDI 운영 연결
- ERP, WMS 또는 TMS 대체
- 회계 원장과 실제 채권 정산
- 머신러닝 판매예측 모델
- 운영 라이선스에 의존하는 AI·포털 기능

2개의 가상 OEM Account와 30~50건의 합성 데이터만으로도 충분히 완성도 높은 포트폴리오를 만들 수 있습니다.

## KPI 제안

| KPI | 의미 |
|---|---|
| 최초 대응시간 | 이슈 발생부터 담당자의 최초 확인까지 걸린 시간 |
| SLA 준수율 | SLA 내 처리된 이슈 비율 |
| 정시 해결률 | 마감일 안에 해결된 이슈 비율 |
| 증빙 1차 완결률 | 재작업 없이 필수 증빙 검증을 통과한 비율 |
| 재오픈율 | 종결 후 다시 열린 이슈 비율 |
| 비용 회수율 | 회수 금액 ÷ 회수 가능한 Claim 금액 |
| 인수인계 누락률 | 담당자 변경 후 미배정 또는 기한 초과된 항목 비율 |
| 중복 이슈율 | 동일 외부 이벤트가 중복 생성된 비율 |
| WAPE | `Σ|Actual - Plan| ÷ ΣActual` |
| Bias | `Σ(Plan - Actual) ÷ ΣActual` |

성과 목표는 임의의 실제 성과처럼 제시하지 않고, 합성 데이터의 기준선과 개선 시나리오임을 명확히 표시하는 것이 좋습니다.

## 포트폴리오 산출물 제안

- As-Is 및 To-Be 업무 흐름도
- ERD
- 상태 전이표
- Persona–Permission Matrix
- Case와 Custom Object 선택 ADR
- EDI Sequence Diagram
- Custom Metadata 정책표
- KPI 정의서
- 합성 샘플 데이터
- Flow, Apex 및 LWC 테스트 결과
- Dashboard 캡처
- 3~5분 데모 영상

## 검토 범위

현재는 기획서만 있고 SFDX 소스와 메타데이터가 없으므로 `platform-architecture-analyze`를 이용한 코드·메타데이터 수준의 Well-Architected 평가는 수행하지 않았습니다. 구현 전 단계의 다음 산출물은 **ERD, 상태 전이표, 객체별 필드 명세 및 핵심 User Story 3개**가 적합합니다.
