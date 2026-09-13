# 구현 화면 기록

Cloud Alpacas (가상의 프로야구 구단 Salesforce CRM 도입 프로젝트) 포트폴리오에 담긴 각 기능이 실제 org에 구현되어 있음을 보여주는 스크린샷 모음입니다.

---

## 01. B2C Fan 360 (Phase 1)

팬 데이터를 표준 오브젝트(Person Account·Product2·Order)와, 표준으로 표현 안 되는 팬 행동·추천 로직을 담는 커스텀 오브젝트 6종으로 나눠 설계했습니다.

| Game\_\_c | Season\_\_c |
|---|---|
| ![Game__c](01_b2c-fan360/game_c%201.png) | ![Season__c](01_b2c-fan360/Season_c%201.png) |

| Fan_Activity_Pattern\_\_c | Recommendations\_\_c |
|---|---|
| ![Fan_Activity_Pattern__c](<01_b2c-fan360/fan activity pattern_c 1.png>) | ![Recommendations__c](<01_b2c-fan360/fan recommendaton_c 1.png>) |

| Notification_Log\_\_c | Fan_Segment_History\_\_c |
|---|---|
| ![Notification_Log__c](<01_b2c-fan360/Notification Log_c 1.png>) | ![Fan_Segment_History__c](<01_b2c-fan360/fan segment history_c 1.png>) |

**실제 레코드 예시** — Game·Fan Activity Pattern이 함께 쌓이는 모습
![Game & Fan Activity Pattern record](<01_b2c-fan360/games, fan activity pattern record.png>)

---

## 02. B2B Sponsorship Opportunity — Product·Quote·Campaign 활성화

*(촬영 예정 — Standard Quote+QuoteLineItem, Campaign Record Type 목록, Opportunity Product, CampaignMember)*

## 03. Campaign 표준 기능 활성화

*(촬영 예정 — Campaign Record Type=Sponsorship_Collaboration, Opportunity의 Primary Campaign Source)*

## 04. [고도화 1단계] Campaign 이행률 추적

*(촬영 예정 — Campaign_Deliverable\_\_c 필드, Related List, Roll-Up 값)*

## 05. [고도화 2단계] Blocked·Slack 알림

*(촬영 예정 — Blocked_Reason\_\_c 피클리스트, Flow Builder, Remote Site Setting, Slack 알림)*

## 06. [고도화 3단계] Agentforce 모니터링

*(촬영 예정 — Agent Router·Bottleneck Monitor·Renewal Report·Ambiguous Question 토픽, 대화 테스트)*

## 07. [고도화 4단계] Campaign Agent Chat

*(촬영 예정 — 임베디드 채팅 LWC, 모달, Named Credential, FlexiPage)*
