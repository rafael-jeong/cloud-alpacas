import { LightningElement, api } from 'lwc';

// 세그먼트별 getFanList Apex 메서드를 정적으로 미리 import
// (LWC는 동적 import 경로를 지원하지 않아 4개를 각각 import 해두고 apexClass 값으로 분기)
import getMembershipFanList from '@salesforce/apex/SegmentMembershipCompleted.getFanList';
import getNoVisitFanList from '@salesforce/apex/SegmentNoVisitAfterSignup.getFanList';
import getDecliningFanList from '@salesforce/apex/SegmentDecliningVisits.getFanList';
import getNoGoodsLoyalFanList from '@salesforce/apex/SegmentNoGoodsLoyal.getFanList';

export default class SegmentFanList extends LightningElement {
    @api segmentId;
    @api title;

    _apexClass;
    @api
    get apexClass() {
        return this._apexClass;
    }
    set apexClass(value) {
        this._apexClass = value;
        if (value) {
            this.loadList();
        }
    }

    fanList;
    error;

    async loadList() {
        this.fanList = undefined;
        this.error = undefined;
        try {
            let data;
            if (this._apexClass === 'SegmentMembershipCompleted') {
                data = await getMembershipFanList();
            } else if (this._apexClass === 'SegmentNoVisitAfterSignup') {
                data = await getNoVisitFanList();
            } else if (this._apexClass === 'SegmentDecliningVisits') {
                data = await getDecliningFanList();
            } else if (this._apexClass === 'SegmentNoGoodsLoyal') {
                data = await getNoGoodsLoyalFanList();
            }
            this.fanList = data || [];
        } catch (e) {
            this.error = e;
        }
    }

    get hasData() {
        return this.fanList != null && this.fanList.length > 0;
    }

    get isEmptyList() {
        return this.fanList != null && this.fanList.length === 0;
    }

    handleSelectFan(event) {
        const fanId = event.currentTarget.dataset.id;
        this.dispatchEvent(
            new CustomEvent('selectfan', { detail: { fanId } })
        );
    }

    handleBack() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
