/**
 * SegmentFanListItem
 * "대상 팬 보기" 리스트에서 각 팬 한 명을 나타내는 공통 데이터 구조.
 * 4개 SegmentXxx 클래스가 공통으로 사용한다 (중복 정의 방지).
 */
public class SegmentFanListItem {
    @AuraEnabled public Id fanId;
    @AuraEnabled public String fanName;
    @AuraEnabled public String detailText; // 세그먼트별로 다른 핵심 지표 (예: "관람비율 65%")

    public SegmentFanListItem(Id fanId, String fanName, String detailText) {
        this.fanId = fanId;
        this.fanName = fanName;
        this.detailText = detailText;
    }
}
