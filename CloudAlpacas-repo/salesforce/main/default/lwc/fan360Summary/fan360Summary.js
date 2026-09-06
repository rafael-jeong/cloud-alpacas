import { LightningElement, api, wire } from 'lwc';
import getFan360 from '@salesforce/apex/Fan360Controller.getFan360';

export default class Fan360Summary extends LightningElement {
    _selectedFanId;

    @api
    get selectedFanId() {
        return this._selectedFanId;
    }
    set selectedFanId(value) {
        this._selectedFanId = value;
        if (!value) {
            this.fan = undefined;
            this.error = undefined;
        }
    }

    // 리스트에서 진입했을 때만 "리스트로 돌아가기" 버튼 표시
    @api showBackToList = false;
    // 어느 세그먼트의 대표/선택 팬인지 (헤더 라벨용)
    @api segmentTitle = '멤버십 전환 완료 팬';

    fan;
    error;

    @wire(getFan360, { fanId: '$_selectedFanId' })
    wiredFan({ error, data }) {
        if (!this._selectedFanId) {
            this.fan = undefined;
            this.error = undefined;
            return;
        }
        if (data) {
            this.fan = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.fan = undefined;
        }
    }

    get hasData() {
        return this.fan != null && this._selectedFanId != null;
    }

    get isEmpty() {
        return !this._selectedFanId;
    }

    get segmentLabel() {
        return this.segmentTitle;
    }

    handleBackToList() {
        this.dispatchEvent(new CustomEvent('backtolist'));
    }
}
