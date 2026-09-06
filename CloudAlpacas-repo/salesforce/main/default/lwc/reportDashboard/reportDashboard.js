import { LightningElement, wire } from 'lwc';
import getReportData from '@salesforce/apex/ReportController.getReportData';

const SEGMENT_COLORS = {
    '핵심 팬': '#FC4E00',
    '충성 팬': '#111111',
    '활동 팬': '#2E7D32',
    '관심 팬': '#9E9E9E',
    '가입 팬': '#D9D9D9',
    '멤버십 팬': '#8B5CF6'
};

export default class ReportDashboard extends LightningElement {
    data;
    error;

    @wire(getReportData)
    wiredData({ error, data }) {
        if (data) {
            this.data = this.transform(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }

    transform(raw) {
        const fmtWon = (n) => '₩' + this.formatAmountShort(n);

        const online = raw.onlineRevenue;
        const stadium = raw.stadiumRevenue;

        return {
            online: {
                label: online.channelLabel,
                amount: fmtWon(online.thisAmount),
                lastAmount: '전월 ' + fmtWon(online.lastAmount),
                percent: online.percentChange,
                isUp: online.isUp,
                changeClass: online.isUp ? 'change change--up' : 'change change--down',
                arrow: online.isUp ? '▲' : '▼'
            },
            stadium: {
                label: stadium.channelLabel,
                amount: fmtWon(stadium.thisAmount),
                lastAmount: '전월 ' + fmtWon(stadium.lastAmount),
                percent: stadium.percentChange,
                isUp: stadium.isUp,
                changeClass: stadium.isUp ? 'change change--up' : 'change change--down',
                arrow: stadium.isUp ? '▲' : '▼'
            },
            segmentTotal: raw.segmentTotal,
            segments: raw.segmentDistribution.map((s) => ({
                ...s,
                dotStyle: `background:${SEGMENT_COLORS[s.label] || '#ccc'};`
            })),
            funnel: raw.funnel.map((f) => ({
                ...f,
                barStyle: `width:${f.percent}%;`
            })),
            tierConversion: raw.tierConversion.map((t) => ({
                ...t,
                barStyle: `width:${t.rate}%;`
            })),
            attendanceToGoods: raw.attendanceToGoods,
            visitToMembership: raw.visitToMembership,
            attendanceBarStyle: `width:${raw.attendanceToGoods.rate}%;`,
            membershipBarStyle: `width:${raw.visitToMembership.rate}%;`
        };
    }

    formatAmountShort(n) {
        if (n == null || n === 0) return '0';
        const millions = n / 1000000;
        return millions.toFixed(1) + 'M';
    }

    get hasData() {
        return this.data != null;
    }
}