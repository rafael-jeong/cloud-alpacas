/**
 * Fan360ControllerTest
 * Fan360Controller.getFan360를 검증한다.
 * 커스텀 필드 의존을 최소화해, 환경에 필드가 일부 없어도 최대한 견고하게 돌도록 구성.
 */
@isTest
private class Fan360ControllerTest {

    @isTest
    static void testGetFan360() {
        // ── 최애 선수 (Contact) — 필수 필드만 ──
        Contact player = new Contact(LastName = '문태양');
        insert player;

        // ── Fan (Account) — 표준 필드 + 최애선수 연결만 ──
        Account fan = new Account(
            Name = '테스트루키',
            Favorite_Player__c = player.Id
        );
        insert fan;

        // ── Season ──
        Season__c season = new Season__c(Total_Games__c = 144);
        insert season;

        // ── Game — Name은 자동번호라 지정 안 함 ──
        Game__c game = new Game__c(Game_Date__c = Date.today());
        insert game;

        // ── Attendance_Record (Admission의 부모) ──
        Attendance_Record__c ar = new Attendance_Record__c(Fan__c = fan.Id);
        insert ar;

        // ── Admission ──
        Admission__c adm = new Admission__c(
            Fan__c = fan.Id,
            Game__c = game.Id,
            Attendance_Record__c = ar.Id,
            Admission_Time__c = DateTime.now()
        );
        insert adm;

        // ── Fan_Activity_Pattern (LTV용) ──
        Fan_Activity_Pattern__c fap = new Fan_Activity_Pattern__c(
            Fan__c = fan.Id,
            Total_Spend__c = 124000
        );
        insert fap;

        // ── Notification_Log (타임라인용) ──
        Notification_Log__c noti = new Notification_Log__c(
            Fan__c = fan.Id,
            Content__c = '환영합니다!',
            Sent_Date__c = DateTime.now()
        );
        insert noti;

        // ── 실행 ──
        Test.startTest();
        Fan360Controller.Fan360Data data = Fan360Controller.getFan360(fan.Id);
        Test.stopTest();

        // ── 검증 (핵심만) ──
        System.assertNotEquals(null, data, 'Fan360Data가 반환되어야 함');
        System.assertEquals('테스트루키', data.fanName, '팬 이름이 일치해야 함');
        System.assertNotEquals(null, data.ltv, 'LTV가 계산되어야 함');
        System.assertNotEquals(null, data.timeline, '타임라인이 존재해야 함');
    }
}
