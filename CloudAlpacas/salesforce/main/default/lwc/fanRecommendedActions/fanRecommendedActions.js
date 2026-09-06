import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getRecommendedActions from '@salesforce/apex/FanDetailController.getRecommendedActions';
import markActionExecuted from '@salesforce/apex/FanDetailController.markActionExecuted';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PRIORITY_CLASS = {
    '높음': 'priority priority--high',
    '중간': 'priority priority--medium',
    '낮음': 'priority priority--low'
};

export default class FanRecommendedActions extends LightningElement {
    @api recordId;

    actions;
    error;
    wiredResult;

    @wire(getRecommendedActions, { fanId: '$recordId' })
    wiredActions(result) {
        this.wiredResult = result;
        const { error, data } = result;
        if (data) {
            this.actions = data.map((a) => ({
                ...a,
                priorityClass: PRIORITY_CLASS[a.priority] || 'priority'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.actions = undefined;
        }
    }

    get hasActions() {
        return this.actions != null && this.actions.length > 0;
    }

    async handleExecute(event) {
        const recId = event.currentTarget.dataset.id;
        try {
            await markActionExecuted({ recommendationId: recId });
            this.dispatchEvent(
                new ShowToastEvent({ title: '조치 완료', message: '해당 액션이 완료 처리되었습니다.', variant: 'success' })
            );
            await refreshApex(this.wiredResult);
        } catch (e) {
            this.dispatchEvent(
                new ShowToastEvent({ title: '오류', message: '처리 중 문제가 발생했습니다.', variant: 'error' })
            );
        }
    }
}