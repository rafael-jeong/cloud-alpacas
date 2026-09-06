import { LightningElement, wire } from 'lwc';
import getRepresentativeFan from '@salesforce/apex/Fan360Controller.getRepresentativeFan';

// 세그먼트별 대표 팬 Id 조회 Apex 메서드 (LWC는 동적 import를 지원하지 않아 4개 모두 미리 import)
import getMembershipRepId from '@salesforce/apex/SegmentMembershipCompleted.getRepresentativeFanId';
import getNoVisitRepId from '@salesforce/apex/SegmentNoVisitAfterSignup.getRepresentativeFanId';
import getDecliningRepId from '@salesforce/apex/SegmentDecliningVisits.getRepresentativeFanId';
import getNoGoodsLoyalRepId from '@salesforce/apex/SegmentNoGoodsLoyal.getRepresentativeFanId';

export default class RecommendationDashboard extends LightningElement {
    // 화면 상태: 'empty' | 'list' | 'detail'
    panelMode = 'empty';

    selectedFanId;
    selectedSegmentTitle = '';
    showBackToList = false;

    // 현재 리스트 모드일 때 어떤 세그먼트인지
    listSegmentId;
    listApexClass;
    listTitle;

    repFanId; // 예전 데모 흐름과의 호환용 (미사용 시 무해)

    @wire(getRepresentativeFan)
    wiredRep({ data }) {
        if (data && data.fanId) {
            this.repFanId = data.fanId;
        }
    }

    get showEmptyState() {
        return this.panelMode === 'empty';
    }
    get showListState() {
        return this.panelMode === 'list';
    }
    get showDetailState() {
        return this.panelMode === 'detail';
    }

    // 좌측 "대상 팬 보기" 클릭 → 리스트 모드로 전환
    handleViewList(event) {
        const { segmentId, apexClass, title } = event.detail;
        this.listSegmentId = segmentId;
        this.listApexClass = apexClass;
        this.listTitle = title;
        this.panelMode = 'list';
    }

    // 좌측 "대표 팬 검토" 클릭 → 해당 세그먼트의 대표 팬을 바로 조회해서 상세로 전환
    async handleFanSelect(event) {
        const { apexClass, title } = event.detail;
        let fanId;
        try {
            if (apexClass === 'SegmentMembershipCompleted') {
                fanId = await getMembershipRepId();
            } else if (apexClass === 'SegmentNoVisitAfterSignup') {
                fanId = await getNoVisitRepId();
            } else if (apexClass === 'SegmentDecliningVisits') {
                fanId = await getDecliningRepId();
            } else if (apexClass === 'SegmentNoGoodsLoyal') {
                fanId = await getNoGoodsLoyalRepId();
            }
        } catch (e) {
            fanId = null;
        }

        if (fanId) {
            this.selectedFanId = fanId;
            this.selectedSegmentTitle = title + ' 대표 팬';
            this.showBackToList = false;
            this.panelMode = 'detail';
        } else {
            // 대표 팬이 없으면(조건 만족 팬 0명) 안내만 하고 detail로 전환하지 않음
            this.panelMode = 'empty';
            this.selectedFanId = undefined;
        }
    }

    // 리스트에서 팬 하나 클릭 → 상세로 전환 (리스트로 돌아가기 버튼 표시)
    handleSelectFanFromList(event) {
        const { fanId } = event.detail;
        this.selectedFanId = fanId;
        this.selectedSegmentTitle = this.listTitle + ' 대상 팬';
        this.showBackToList = true;
        this.panelMode = 'detail';
    }

    // 상세 화면의 "리스트로 돌아가기" 클릭
    handleBackToList() {
        this.selectedFanId = undefined;
        this.panelMode = 'list';
    }

    // 리스트 화면의 "뒤로" 클릭 (리스트 자체를 닫고 초기 상태로)
    handleCloseList() {
        this.panelMode = 'empty';
    }
}
