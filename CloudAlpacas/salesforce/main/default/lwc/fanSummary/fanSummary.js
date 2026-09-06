import { LightningElement, api, wire } from 'lwc';
import getFanSummary from '@salesforce/apex/FanDetailController.getFanSummary';

export default class FanSummary extends LightningElement {
    @api recordId;

    summary;
    error;

    @wire(getFanSummary, { fanId: '$recordId' })
    wiredSummary({ error, data }) {
        if (data) {
            this.summary = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summary = undefined;
        }
    }

    get hasData() {
        return this.summary != null;
    }

    // 도넛 차트용 — 점수(0~100)를 원 둘레 비율로 변환
    get donutStyle() {
        const score = this.summary ? this.summary.engagementScore : 0;
        const circumference = 2 * Math.PI * 45; // r=45
        const offset = circumference - (circumference * score) / 100;
        return `stroke-dasharray:${circumference};stroke-dashoffset:${offset};`;
    }

    get ltvFormatted() {
        if (!this.summary) return '₩0';
        return '₩' + this.summary.ltv.toLocaleString('ko-KR');
    }
}