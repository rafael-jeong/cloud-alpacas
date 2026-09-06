# 03. ERD

**이 페이지가 답하는 질문**: Object들이 서로 어떻게 연결되나요?

> 오늘 가장 중요한 페이지입니다. A3로 인쇄해서 손으로 관계를 더 그려도 됩니다.

---

## ① Business ERD

```mermaid
graph TD
    Fan["팬<br/>(이루키)"] -->|좋아함| Player["선수"]
    Fan -->|산다| Product["상품<br/>(티켓/시즌권/멤버십/굿즈)"]
    Product -->|거래로 이어짐| Purchase["구매"]
    Purchase -->|경기 티켓이면| Game["경기"]
    Purchase -->|입장하면| Admission["입장 기록"]
    Admission -->|쌓이면| Attendance["누적 관람 이력"]
    Fan -->|관심을 보이면| Signal["관심 신호"]
    Fan -->|상태가 바뀌면| Segment["팬 상태"]
    Segment -->|근거가 되어| Recommend["추천 액션"]
    Recommend -->|실행되면| Benefit["혜택"]
    Segment -->|대상이 되어| Campaign["캠페인"]
    Campaign -->|발송하면| Notify["안내"]
    Fan -->|문의하면| Inquiry["문의"]
    Inquiry -.-> Purchase

    style Fan fill:#fff4cc,stroke:#333
```

---

## ② Salesforce ERD

```mermaid
graph TD
    subgraph Fan축["Fan 축"]
        F["Person Account<br/>(Fan)"]
        P["Contact<br/>(Player)"]
        ES[Engagement_Signal__c]
        FAP[Fan_Activity_Pattern__c]
        FSH[Fan_Segment_History__c]
        REC[Recommendation__c]
        BEN[Benefit__c]
        CASE[Case]
    end

    subgraph Ops축["Operations 축"]
        PR[Product2]
        PBE[PricebookEntry]
        G["Game__c"]
        O[Order]
        OI[OrderItem]
        AD["Admission__c"]
        AR[Attendance_Record__c]
    end

    subgraph Mkt축["Marketing 축"]
        C[Campaign]
        CM[CampaignMember]
        NL[Notification_Log__c]
    end

    F -->|Favorite_Player__c| P
    F --> ES
    P --> ES
    F --> FAP
    F --> FSH
    F --> REC --> BEN
    F --> BEN
    F -->|Related_Order__c| CASE

    F --> O
    G --> O
    PR --> PBE --> OI
    O --> OI
    OI -->|입장 시| AD
    G --> AD
    AD --> AR
    F --> AR
    O --> CASE

    FSH --> CM
    C --> CM --> F
    C -->|발송| NL --> F

    style F fill:#fff4cc,stroke:#333
```

---

## ③ 전체 Object Map (참고 이미지)

![Cloud Alpacas ERD](./cloud-alpacas-erd.png)

> 이 이미지는 **Workshop/팀 논의용 시각적 참고 자료**다 — Standard Object/Custom
> Object를 한눈에 보여준다. **공식 Object 관계 정의는 `docs/03_SYSTEM.md` §3.4
> Relationship Summary의 Mermaid `erDiagram`**이며, 관계가 바뀌면 그 문서를 먼저
> 고친다 — 이 이미지는 정적 파일이라 자동으로 갱신되지 않는다.
