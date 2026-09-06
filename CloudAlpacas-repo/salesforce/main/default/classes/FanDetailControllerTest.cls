@isTest
private class FanDetailControllerTest {

    @isTest
    static void testFanDetailData() {
        Account fan = new Account(LastName = '테스트팬', Engagement_Score__c = 74, Engagement_Level__c = '활동 팬');
        insert fan;

        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;

        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;
        Game__c game = new Game__c(Game_Date__c = Date.today(), Season__c = season.Id, Opponent__c = '레드폭스');
        insert game;

        insert new Admission__c(Fan__c = fan.Id, Game__c = game.Id, Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now());

        Order o = new Order(AccountId = fan.Id, Status = 'Activated', EffectiveDate = Date.today(),
            Order_Type__c = 'Ticket Purchase', Purchase_Channel__c = 'Online',
            Pricebook2Id = Test.getStandardPricebookId());
        insert o;

        insert new Fan_Activity_Pattern__c(Fan__c = fan.Id, Total_Spend__c = 50000);

        insert new Notification_Log__c(Fan__c = fan.Id, Content__c = '테스트 알림', Sent_Date__c = DateTime.now());

        insert new Case(AccountId = fan.Id, Subject = '테스트 문의', Status = 'Closed');

        Recommendations__c rec = new Recommendations__c(
            Fan__c = fan.Id, Recommended_Action__c = 'Membership Campaign',
            Reason__c = '테스트 사유', Status__c = 'Pending'
        );
        insert rec;

        Test.startTest();
        FanDetailController.FanSummary summary = FanDetailController.getFanSummary(fan.Id);
        List<FanDetailController.ActionCard> actions = FanDetailController.getRecommendedActions(fan.Id);
        List<FanDetailController.TimelineItem> timeline = FanDetailController.getFanTimeline(fan.Id);
        FanDetailController.markActionExecuted(rec.Id);
        Test.stopTest();

        System.assertEquals(74, summary.engagementScore, '참여도 점수가 일치해야 함');
        System.assertEquals(1, actions.size(), '대기중 추천 1건이어야 함');
        System.assertEquals('높음', actions[0].priority, 'Membership Campaign은 높음 우선순위');
        System.assert(timeline.size() >= 3, '타임라인에 최소 3건 이상 있어야 함');

        Recommendations__c updated = [SELECT Status__c FROM Recommendations__c WHERE Id = :rec.Id];
        System.assertEquals('Executed', updated.Status__c, '조치 완료 처리되어야 함');
    }
}
