import { LightningElement, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUpsellData from '@salesforce/apex/SponsorUpsellController.getUpsellData';
import sendToSlack from '@salesforce/apex/SponsorUpsellReportSender.sendToSlack';
import CLOUD_ALPACAS_CSS from '@salesforce/resourceUrl/cloudAlpacas';

const TIER_META = {
    Gold: { label: 'Gold' },
    Platinum: { label: 'Platinum' },
    Diamond: { label: 'Diamond' }
};

/** Format a KRW amount into a compact "조"/"억"/"만" label. */
function won(n) {
    if (n === null || n === undefined) return '-';
    const abs = Math.abs(n);
    if (abs >= 1000000000000) return (n / 1000000000000).toFixed(abs % 1000000000000 === 0 ? 0 : 1) + '조';
    if (abs >= 100000000) return (n / 100000000).toFixed(abs % 100000000 === 0 ? 0 : 1) + '억';
    if (abs >= 10000) return Math.round(n / 10000) + '만';
    return Number(n).toLocaleString('ko-KR');
}

export default class SponsorUpsellPanel extends LightningElement {
    @api recordId;
    data;
    error;
    sending = false;
    _stylesLoaded = false;

    connectedCallback() {
        if (this._stylesLoaded) return;
        this._stylesLoaded = true;
        loadStyle(this, CLOUD_ALPACAS_CSS).catch(() => {
            // 공통 CSS 로드 실패 시에도 로컬 fallback 값으로 동작
            this._stylesLoaded = false;
        });
    }

    @wire(getUpsellData, { recordId: '$recordId' })
    wired({ data, error }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error?.body?.message || '데이터를 불러오지 못했습니다.';
            this.data = undefined;
        }
    }

    get hasData() {
        return !!this.data;
    }

    // ── 헤드라인 카드 1: 현재 등급 (hero) ──────────────────────────────
    get currentTierLabel() {
        return this.data?.currentTier ? TIER_META[this.data.currentTier]?.label : '미분류';
    }
    get totalValueLabel() {
        return won(this.data?.totalValue);
    }
    get contractYearsLabel() {
        return `계약 ${this.data?.contractYears ?? 0}시즌 · 누적 ${this.totalValueLabel}`;
    }
    get heroBars() {
        // 시즌별 계약금액 추이를 hero 카드 하단 미니 막대로
        return (this.data?.history || []).map((h, i, arr) => ({
            year: h.year,
            style: `height:${Math.max(h.pct, 8)}%;`,
            barClass: i === arr.length - 1 ? 'su-hero-bar su-hero-bar--last' : 'su-hero-bar'
        }));
    }

    // ── 헤드라인 카드 2: 전년 대비 성장 ────────────────────────────────
    get growthValue() {
        const g = this.data?.yoyGrowth;
        if (g === null || g === undefined) return '–';
        return (g >= 0 ? '+' : '') + g + '%';
    }
    get growthPositive() {
        return (this.data?.yoyGrowth ?? 0) >= 0;
    }
    get growthBadgeClass() {
        return this.growthPositive
            ? 'su-metric-badge su-metric-badge--up'
            : 'su-metric-badge su-metric-badge--down';
    }
    get growthBadgeLabel() {
        return this.growthPositive ? '성장' : '감소';
    }

    // ── 헤드라인 카드 3: 다음 등급 목표 ────────────────────────────────
    get targetTierLabel() {
        return TIER_META[this.data?.targetTier]?.label || this.data?.targetTier;
    }
    get priceDeltaLabel() {
        return this.data?.priceDelta ? '+' + won(this.data.priceDelta) : null;
    }
    get isTopTier() {
        return !!this.data?.isTopTier;
    }
    // 다음 등급 권리 중 이미 보유한 비율 → 도넛/진행도
    get targetProgress() {
        const rights = this.data?.upsellRights || [];
        const total = rights.length;
        if (total === 0) return null;
        const held = total - (this.data?.newRightCount ?? 0);
        const pct = Math.round((held / total) * 100);
        const circumference = 314; // r=50
        const arc = Math.round((pct / 100) * circumference);
        return {
            pct,
            heldLabel: `${held}/${total}`,
            dashStyle: `stroke-dasharray:${arc} ${circumference - arc};`,
            barStyle: `width:${pct}%;`
        };
    }
    get targetFootnote() {
        if (this.isTopTier) return '최상위 등급 · 프리미엄 권리 딥셀';
        const delta = this.priceDeltaLabel;
        return delta ? `승급 시 연 ${delta} 규모` : '다음 등급 승급 대상';
    }

    // ── 등급 사다리 ────────────────────────────────────────────────────
    get ladderSteps() {
        return (this.data?.ladder || []).map((s) => {
            let cls = 'su-tier-step';
            if (s.isCurrent) cls += ' su-tier-step--current';
            else if (s.isTarget) cls += ' su-tier-step--target';
            else if (s.isAchieved) cls += ' su-tier-step--achieved';
            return {
                key: s.name,
                name: TIER_META[s.name]?.label || s.name,
                priceLabel: won(s.price),
                cls,
                isCurrent: s.isCurrent,
                isTarget: s.isTarget
            };
        });
    }

    // ── 혜택 갭 ────────────────────────────────────────────────────────
    get upsellHeadline() {
        if (!this.data) return '';
        if (this.data.isTopTier) {
            return `미보유 프리미엄 권리 ${this.data.newRightCount}건`;
        }
        return `${this.targetTierLabel} 승급 시 신규 권리 ${this.data.newRightCount}건`;
    }
    get rightItems() {
        return (this.data?.upsellRights || []).map((r) => ({
            code: r.code,
            name: r.name,
            cls: 'su-chip ' + (r.held ? 'su-chip--held' : 'su-chip--new'),
            icon: r.held ? '✓' : '+'
        }));
    }

    // ── 준비도 신호 ────────────────────────────────────────────────────
    get signals() {
        if (!this.data) return [];
        const d = this.data;
        const out = [];
        if (d.yoyGrowth !== null && d.yoyGrowth !== undefined) {
            out.push({
                key: 'growth', label: '전년 대비 계약금액',
                value: (d.yoyGrowth >= 0 ? '+' : '') + d.yoyGrowth + '%',
                dotClass: d.yoyGrowth >= 0 ? 'su-sig-dot su-sig-dot--good' : 'su-sig-dot su-sig-dot--bad'
            });
        }
        out.push({
            key: 'years', label: '연속 계약',
            value: (d.contractYears ?? 0) + '시즌',
            dotClass: (d.contractYears ?? 0) >= 3 ? 'su-sig-dot su-sig-dot--good' : 'su-sig-dot su-sig-dot--bad'
        });
        if (d.operatingProfit) {
            out.push({
                key: 'op', label: '영업이익 (DART)',
                value: won(d.operatingProfit),
                dotClass: d.operatingProfit > 0 ? 'su-sig-dot su-sig-dot--good' : 'su-sig-dot su-sig-dot--bad'
            });
        }
        if (d.totalAssets) {
            out.push({
                key: 'assets', label: '자산총계 (DART)',
                value: won(d.totalAssets),
                dotClass: 'su-sig-dot su-sig-dot--good'
            });
        }
        return out;
    }

    // ── Slack으로 발송 ─────────────────────────────────────────────────
    handleSendSlack() {
        if (this.sending || !this.recordId) return;
        this.sending = true;
        sendToSlack({ recordId: this.recordId })
            .then((msg) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Slack 발송',
                    message: msg || '파트너십 업셀 플랜을 Slack으로 발송했습니다.',
                    variant: 'success'
                }));
            })
            .catch((e) => {
                this.dispatchEvent(new ShowToastEvent({
                    title: '발송 실패',
                    message: e?.body?.message || 'Slack 발송 중 오류가 발생했습니다.',
                    variant: 'error'
                }));
            })
            .finally(() => {
                this.sending = false;
            });
    }
}