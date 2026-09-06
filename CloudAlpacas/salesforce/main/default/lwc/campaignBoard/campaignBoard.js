import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getCampaigns from '@salesforce/apex/CampaignController.getCampaigns';

export default class CampaignBoard extends NavigationMixin(LightningElement) {
    activeCampaigns = [];
    endedCampaigns = [];
    error;
    showEnded = false;

    @wire(getCampaigns)
    wiredCampaigns({ error, data }) {
        if (data) {
            const mapped = data.map((c) => ({
                ...c,
                progressStyle: `width: ${c.progress}%;`,
                badgeClass: this.badgeClass(c.status),
                barClass: c.status === '종료' ? 'bar-fill bar-fill--done' : 'bar-fill'
            }));
            // 진행 중 / 예약됨은 위, 종료는 아래 모아보기
            this.activeCampaigns = mapped.filter((c) => c.status !== '종료');
            this.endedCampaigns = mapped.filter((c) => c.status === '종료');
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.activeCampaigns = [];
            this.endedCampaigns = [];
        }
    }

    badgeClass(status) {
        if (status === '진행 중') return 'badge badge--active';
        if (status === '예약됨') return 'badge badge--scheduled';
        return 'badge badge--done';
    }

    get hasActive() {
        return this.activeCampaigns.length > 0;
    }

    get hasEnded() {
        return this.endedCampaigns.length > 0;
    }

    get endedToggleLabel() {
        return this.showEnded
            ? `종료된 캠페인 숨기기 (${this.endedCampaigns.length})`
            : `종료된 캠페인 모아보기 (${this.endedCampaigns.length})`;
    }

    get endedSectionClass() {
        return this.showEnded ? 'ended-section ended-section--open' : 'ended-section';
    }

    toggleEnded() {
        this.showEnded = !this.showEnded;
    }

    handleNewCampaign() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Campaign',
                actionName: 'new'
            }
        });
    }
}