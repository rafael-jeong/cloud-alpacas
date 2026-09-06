import { LightningElement, api, wire } from 'lwc';
import getFanTimeline from '@salesforce/apex/FanDetailController.getFanTimeline';

const TYPE_CLASS = {
    '티켓 구매': 'badge badge--ticket',
    '굿즈 구매': 'badge badge--goods',
    '경기장 방문': 'badge badge--visit',
    '캠페인 반응': 'badge badge--campaign',
    '문의': 'badge badge--case'
};

export default class FanTimeline extends LightningElement {
    @api recordId;

    timeline;
    error;

    @wire(getFanTimeline, { fanId: '$recordId' })
    wiredTimeline({ error, data }) {
        if (data) {
            this.timeline = data.map((t) => ({
                ...t,
                badgeClass: TYPE_CLASS[t.type] || 'badge'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.timeline = undefined;
        }
    }

    get hasData() {
        return this.timeline != null && this.timeline.length > 0;
    }
}