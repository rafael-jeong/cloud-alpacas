import { LightningElement, api, wire } from 'lwc';
import getGameDetail from '@salesforce/apex/GameDetailController.getGameDetail';

export default class GameDetail extends LightningElement {
    // Record Page에 놓으면 그 경기(Game__c)의 Id가 자동으로 들어옴
    @api recordId;

    game;
    error;

    @wire(getGameDetail, { gameId: '$recordId' })
    wiredGame({ error, data }) {
        if (data) {
            this.game = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.game = undefined;
        }
    }

    get hasData() {
        return this.game != null;
    }

    get seatBarStyle() {
        return `width: ${this.game ? this.game.seatRate : 0}%;`;
    }

    get seatRateLabel() {
        return this.game ? this.game.seatRate + '% 판매' : '';
    }
}