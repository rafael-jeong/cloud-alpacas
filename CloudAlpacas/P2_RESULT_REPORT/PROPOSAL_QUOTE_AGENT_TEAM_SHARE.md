# Proposal/Quote Subagent — 팀 공유 (완료 보고)

> ⚠️ **✅ 2026-08-31 SUPERSEDED** — 이 보고서가 다루는 산출물(PermSet+Apex 3개, 커밋 `f762840f`)은 merge되지 않았고, Eunyeong Doh가 독립적으로 다시 만든 동명 구현이 공식 채택됐다. 상세 경위는 `docs/05_DECISIONS.md` Decision 021 "2026-08-31 최종 갱신" 참고. 이 문서는 삭제하지 않고 그대로 보존한다.
>
> 이 문서는 git 저장소에 커밋되어 팀과 공유됩니다(`AI_HANDOFF_CONTEXT.md`/`SLACK_MCP_HANDOFF_CONTEXT.md`와 달리 로컬 전용 아님 — 2026-08-27 승우 판단으로 예외 적용).
> 작성일: 2026-08-27 / 작성자: 승우(Rafael Espada) 요청, Claude 작성
> **목적**: 이 작업을 직접 하지 않은 팀원, 그리고 팀원들이 쓰는 AI 세션이 이 내용을 정확히 이어받을 수 있도록 사실 위주로 기록합니다. 추측·평가는 최소화하고, 실제로 확인된 것과 아직 확인 안 된 것을 명확히 구분합니다.

---

## 1. 한 줄 요약

Opportunity 영역 Agentforce 아키텍처 공유(2026-08-27, "메인 Opportunity Agent + 전문 Subagent 5개" 구조 — Activity Management / Deal Intelligence / Discovery Management / **Proposal / Quote** / Negotiation) 중 **Proposal / Quote** 담당분을 승우가 독립 Agent(`Sponsorship_Proposal_Assistant`)로 개발·배포·Live Preview까지 완료했습니다. **Publish/Activate는 하지 않았고, 메인 Opportunity Agent에 연결하지도 않았습니다** — 팀 방침대로 각자 독립 개발 후 마지막에 담당자가 통합하는 방식을 따릅니다.

---

## 2. 만든 것 — 정확한 산출물 목록

### 2.1 Agent (AiAuthoringBundle)

- 경로: `salesforce/main/default/aiAuthoringBundles/Sponsorship_Proposal_Assistant/`
- `developer_name`: `Sponsorship_Proposal_Assistant`
- `agent_type`: `AgentforceEmployeeAgent`(내부 사용자용, `access.default_agent_user` 없음)
- 구조: Router 없이 **단일 `start_agent proposal_quote:`** — 팀 통합 시 이 `proposal_quote`라는 이름 그대로 메인 Opportunity Agent의 `subagent` 블록으로 옮겨 붙이기 쉽게 설계함
- Action 3개(전부 Invocable Apex):
  - `get_opportunity_context` → `apex://OpportunityProposalContext`(조회 전용)
  - `list_sponsorship_packages` → `apex://SponsorshipPackageLookup`(조회 전용)
  - `save_proposal` → `apex://SponsorshipProposalSaver`(Create만, Delete 없음 — 팀 방침 준수)
- Delete Action 없음(팀 방침 §5 준수)
- 표준 Action 대체 여부는 API `InvocableActionsApiFamily`가 이 Org에서 비활성화되어 있어 확인 못 함(§6 참고) — Setup UI에서 별도 확인 필요

### 2.2 Apex 클래스 (신규 3개, 전부 배포 완료)

| 클래스 | 역할 | DML 여부 |
|---|---|---|
| `OpportunityProposalContext` | Opportunity + (있으면) 전환된 Lead의 B2B 필드 조회 | 없음(Read only) |
| `SponsorshipPackageLookup` | Active Sponsorship Package(Product2) + Standard Price Book 가격 조회 | 없음(Read only) |
| `SponsorshipProposalSaver` | Quote+QuoteLineItem 생성, Opportunity 필드 갱신 | **있음** — `proposal_confirmed` 게이트로 보호됨 |

경로: `salesforce/main/default/classes/{OpportunityProposalContext,SponsorshipPackageLookup,SponsorshipProposalSaver}.cls(+meta.xml)`

### 2.3 설계 문서

- `P2_RESULT_REPORT/Sponsorship_Proposal_Assistant-AgentSpec.md` — Agent Spec 전체(Action I/O, 변수, 게이팅 로직, 검증 로그 포함)

---

## 3. 공유 리소스에 생긴 변경 — 다른 사람/다른 AI가 반드시 알아야 하는 것

### 3.1 `sfdx-project.json` — `sourceApiVersion` 58.0 → 67.0 (프로젝트 전체 영향)

`AiAuthoringBundle` 메타데이터가 API v66.0 이상을 요구해서 올렸습니다. **이 프로젝트에서 앞으로 배포하는 모든 메타데이터에 영향을 주는 변경**입니다. 로컬에 예전 버전을 가정한 스크립트/문서가 있다면 확인 필요.

### 3.2 `CA_Opportunity_Agent_Access` PermSet — 최소 권한 추가 (은영님 기존 설정은 전부 보존)

병합 방식으로 배포했고(기존 내용 retrieve → 추가 → redeploy), 기존에 있던 Discovery/Interaction Intelligence/Interaction Signal 관련 권한은 손대지 않았습니다. 이번에 추가한 것만 아래에 정리합니다.

**Object 권한 추가:**
| Object | Read | Create | Edit | Delete |
|---|---|---|---|---|
| Lead | ✅ | - | - | - |
| Product2 | ✅ | - | - | - |
| Pricebook2 | ✅ | - | - | - |
| Quote | ✅ | ✅ | - | - |

(`PricebookEntry`, `QuoteLineItem`은 의도적으로 추가 안 함 — §6.2 참고, 부모 Object 권한에서 상속되는 유형이라 독립 설정 자체가 불가능함)

**Field 권한 추가(전부 Delete 없음, 팀 방침 §5 준수):**
- `Opportunity.Expected_Benefit_Short_Term__c` / `Mid_Term__c` / `Long_Term__c` — Read+Edit
- `Opportunity.Partner_Tier__c` — Read only
- `Lead.Target_Segment__c` / `Segment_Match__c` / `Recommendation_Reason__c` / `Lead_Score__c` — Read only

### 3.3 `PRM_Manager_Access` PermSet — 별개 이슈, 이미 해결·기록됨

이번 작업 중 실수로 혜준님이 8/18 만든 이 PermSet의 Lead/Account/Contact 권한을 일시적으로 지웠다가 Setup Audit Trail로 복구했습니다. **이건 Agent용이 아니라 사람이 Salesforce 화면을 쓸 때의 권한**이라 §3.2와는 별개 건입니다. 상세 경위는 `docs/decision_sheet/P2_B2B_ORG_BASELINE.md §17`에 전부 기록되어 있습니다. 배정된 사용자가 0명이라 실사용자 피해는 없었습니다.

### 3.4 Live Preview로 실제 생성된 테스트 데이터 (Org에 실제로 남아있음)

`d'Alba Long-Term Sponsorship` Opportunity(`006bm00000VonmrAAB`)에 아래가 실제로 생성/변경되어 있습니다. **삭제하지 않았으니, 데모/다른 용도로 이 Opportunity를 쓸 계획이 있다면 확인 필요:**
- Quote `0Q0bm000003F6rNCAS`("d'Alba 전광판 광고 + Brand Day 패키지 제안") + QuoteLineItem 1건(11억, 전광판 광고 + Brand Day 패키지)
- Opportunity의 `Expected_Benefit_Short_Term__c`/`Mid_Term__c`/`Long_Term__c` 3개 필드에 테스트용 초안 내용이 실제로 채워짐

---

## 4. 검증 완료 사항

| 검증 | 결과 |
|---|---|
| 로컬 Agent Script 컴파일러 | 통과(진단 0건) |
| Org 대상 `sf agent validate authoring-bundle` | 통과 |
| Simulated Preview(가짜 데이터) | 추천/초안/확인 게이트/중복 저장 방지 4개 시나리오 전부 정상 |
| **Live Preview(실제 Org 데이터, `--use-live-actions`)** | Opportunity 조회 → 실제 가격으로 패키지 추천 → 초안 → 명시적 확인 → 실제 Quote/QuoteLineItem 생성 → Opportunity 갱신까지 **SOQL로 직접 재확인 완료** |
| Publish / Activate | **하지 않음**(Draft 유지 원칙) |

---

## 5. 이번에 발견한 Org/플랫폼 특이사항 (다른 Agent 작업 시 참고)

다른 Subagent(Activity Management, Deal Intelligence, Discovery Management, Negotiation)를 개발하는 팀원/AI가 똑같은 문제에 부딪히지 않도록 기록합니다.

1. **Record Id를 주고받는 Action Input/Output은 `string`이 아니라 `object` + `complex_data_type_name: "lightning__recordIdType"`로 선언해야 합니다.** 이 오류는 로컬 컴파일러·`sf agent validate`·Simulated Preview **전부 통과한 뒤, Live Preview 세션 시작 시점에만** 드러났습니다. Record Id를 다루는 Action이 있다면 미리 이렇게 선언하세요.
2. **`PricebookEntry`, `QuoteLineItem`은 Permission Set에서 독립적인 Object 권한을 가질 수 없습니다** — 각각 `Product2`/`Pricebook2`, `Quote`에서 상속됩니다. Setup UI(Permission Set > Object Settings)에서 이 두 Object는 Object Permission 칸이 "No Access"가 아니라 **"--"**로 표시됩니다("--" = 설정 자체가 불가, "No Access"와 다른 의미). 이 둘에 대해 Permission Set 배포 시 명시적으로 권한을 넣어도 에러 없이 조용히 무시되니, 부모 Object 권한만 확인하면 됩니다.
3. **커스텀 필드 존재 여부 확인은 Tooling API `FieldDefinition` 쿼리로 하지 마세요** — 이번 세션에서 방금 배포 성공한 필드조차 이 쿼리로 조회가 안 되는 현상을 겪었습니다. `sf sobject describe --sobject <Object> --json`을 쓰세요(baseline 문서도 원래 이 방식으로 작성됨).
4. **로컬 Agent Script 컴파일러 설치 스크립트(`setup-agentscript-sdk.mjs --npm`)가 이 Windows 환경에서 `spawnSync npm ENOENT`로 실패합니다.** npm 자체는 정상 작동하는데 스크립트의 내부 호출 방식 문제로 보입니다. 해결: `<cache>/agentscript-sdk/npm/sf-agentscript-agentforce-2.9.27/`에 직접 `npm install --ignore-scripts --no-audit --no-fund --save-exact @sf-agentscript/agentforce@2.9.27` 실행 후 setup 스크립트를 다시 돌리면(이미 `node_modules`가 있어서 npm 재호출 없이) 정상적으로 매니페스트가 써집니다. 캐시 기본 경로: `~/.cache/agentforce-generate`.
5. **`AiAuthoringBundle`은 API v66.0 이상 필요**(§3.1 참고).

---

## 6. 아직 안 한 것 / 팀에서 결정 필요한 것

1. **메인 Opportunity Agent 통합** — 팀 방침대로 담당자가 마지막에 진행. 이 Agent의 `proposal_quote` subagent 블록 + Action 3개를 그대로 옮기면 됩니다.
2. **§3.4의 테스트 데이터 정리 여부** — 그대로 둘지, 삭제할지 팀 논의 필요.
3. **`CA_Opportunity_Agent_Access`를 실제 비Admin 사용자에게 배정해서 최종 검증** — 지금은 배정된 유일한 사용자(은영님)도 System Administrator라, 일반 사용자 권한으로 완전히 검증된 상태는 아닙니다(단, §5-2 설계상 문제 없을 것으로 판단됨).

**✅ 완료됨 — 표준 Action 대체 여부 확인**: Agentforce Builder Asset Library(281개)를 `opportunity`/`quote`/`lead`/`product`/`pricebook`/`price` 키워드로 전부 검색 완료(2026-08-27, 승우). 전부 무관한 용도(AI 분석/추천, Data Cloud, Service/Commerce 데모)뿐이라 **대체 불가 — Apex 3개 유지 확정**. 다른 Subagent(Activity/Deal Intelligence/Discovery/Negotiation) 담당자도 같은 검색을 반복할 필요 없이 이 결론을 참고하면 됩니다(단, 본인 Action이 다루는 Object/필드가 다르면 재검색 권장).

---

## 7. 참고 문서

- `P2_RESULT_REPORT/Sponsorship_Proposal_Assistant-AgentSpec.md` — 이 Agent의 전체 설계·Action I/O 명세
- `docs/decision_sheet/P2_B2B_ORG_BASELINE.md` §15~18 — Org 재검증 결과, PRM_Manager_Access 사고 경위, 방법론 주의사항
