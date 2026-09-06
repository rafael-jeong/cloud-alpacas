import { LightningElement, api, wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUpsellData from '@salesforce/apex/SponsorUpsellController.getUpsellData';
import sendToSlack from '@salesforce/apex/SponsorUpsellReportSender.sendToSlack';
import saveClientPdf from '@salesforce/apex/SponsorUpsellReportSender.saveClientPdf';
import CLOUD_ALPACAS_CSS from '@salesforce/resourceUrl/cloudAlpacas';
import HTML2CANVAS_URL from '@salesforce/resourceUrl/CA_html2canvas';
import JSPDF_URL from '@salesforce/resourceUrl/CA_jsPDF';

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

/** Format a large count (impressions 등) into 억/만 단위. */
function count(n) {
    if (n === null || n === undefined) return '-';
    const abs = Math.abs(n);
    if (abs >= 100000000) return (n / 100000000).toFixed(abs % 100000000 === 0 ? 0 : 1) + '억';
    if (abs >= 10000) return Math.round(n / 10000).toLocaleString('ko-KR') + '만';
    return Number(n).toLocaleString('ko-KR');
}

export default class SponsorUpsellPanel extends LightningElement {
    @api recordId;
    data;
    error;
    sending = false;
    _stylesLoaded = false;
    _libsPromise = null;

    connectedCallback() {
        if (this._stylesLoaded) return;
        this._stylesLoaded = true;
        loadStyle(this, CLOUD_ALPACAS_CSS).catch(() => {
            // 공통 CSS 로드 실패 시에도 로컬 fallback 값으로 동작
            this._stylesLoaded = false;
        });
        // PDF 캡처 라이브러리는 미리 백그라운드로 로드 (버튼 클릭 시 대기 최소화)
        this.ensureLibsLoaded().catch(() => {
            // 실패해도 버튼 클릭 시 재시도
            this._libsPromise = null;
        });
    }

    ensureLibsLoaded() {
        if (this._libsPromise) return this._libsPromise;
        this._libsPromise = Promise.all([
            loadScript(this, HTML2CANVAS_URL),
            loadScript(this, JSPDF_URL)
        ]);
        return this._libsPromise;
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

    // ── 시즌별 계약금액 추이 (상세 섹션 · 연도/금액 라벨 포함) ────────────
    get trendBars() {
        const hist = this.data?.history || [];
        return hist.map((h, i, arr) => ({
            year: h.year,
            amountLabel: won(h.amount),
            style: `height:${Math.max(h.pct, 8)}%;`,
            colClass: i === arr.length - 1 ? 'su-trend-col su-trend-col--last' : 'su-trend-col'
        }));
    }
    get hasTrend() {
        return (this.data?.history || []).length > 0;
    }
    // 5개년 CAGR (연평균 성장률) — history 첫 시즌 대비 마지막 시즌
    get cagrLabel() {
        const hist = this.data?.history || [];
        if (hist.length < 2) return null;
        const first = hist[0].amount;
        const last = hist[hist.length - 1].amount;
        if (!first || first <= 0) return null;
        const years = hist.length - 1;
        const cagr = (Math.pow(last / first, 1 / years) - 1) * 100;
        return `누적 ${this.totalValueLabel} · CAGR ${cagr.toFixed(1)}%`;
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

    // ── 직전 시즌 성과 (스폰서십 ROI 증빙) ─────────────────────────────
    get hasPerformance() {
        return !!this.data?.hasPerformance;
    }
    get perfSeasonTitle() {
        const s = this.data?.perfSeason;
        return (s ? s + ' ' : '') + '시즌 성과';
    }
    get perfRoiLabel() {
        return this.data?.perfRoi != null ? `ROI ${this.data.perfRoi}%` : null;
    }
    get perfTiles() {
        const d = this.data;
        if (!d) return [];
        const tiles = [];
        if (d.mediaValue != null) tiles.push({ key: 'ave', label: '광고환산가치 (AVE)', value: won(d.mediaValue) });
        if (d.impressions != null) tiles.push({ key: 'imp', label: '총 노출', value: count(d.impressions) });
        if (d.broadcastMin != null) tiles.push({ key: 'br', label: '중계 노출', value: Number(d.broadcastMin).toLocaleString('ko-KR') + '분' });
        if (d.fanEngagement != null) tiles.push({ key: 'fe', label: '팬 인게이지먼트', value: d.fanEngagement + '%' });
        if (d.brandLift != null) tiles.push({ key: 'bl', label: '브랜드 인지도', value: '+' + d.brandLift + '%p' });
        return tiles;
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
    get benefitMeta() {
        const rights = this.data?.upsellRights || [];
        if (rights.length === 0) return '';
        const total = rights.length;
        const newCount = this.data?.newRightCount ?? 0;
        return `보유 ${total - newCount} · 신규 ${newCount}`;
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

    // ── 스폰서십 계약 이행 현황 (라이브) ───────────────────────────────
    showDeliverables = false;

    get fulfillment() {
        return this.data?.fulfillment;
    }
    get hasFulfillment() {
        return !!this.fulfillment?.hasData;
    }
    get fulfillmentRate() {
        return this.fulfillment ? this.fulfillment.rate : 0;
    }
    get fulfillmentBarStyle() {
        return `width:${this.fulfillmentRate}%;`;
    }
    get fulfillmentBarClass() {
        if (!this.fulfillment) return 'su-fx-bar-fill';
        return this.fulfillment.blocked > 0 ? 'su-fx-bar-fill su-fx-bar-fill--warn' : 'su-fx-bar-fill';
    }
    get fulfillmentSummary() {
        const f = this.fulfillment;
        if (!f) return '';
        return `이행률 ${f.rate}% · ${f.total}개 중 ${f.fulfilled}개 완료 · ${f.blocked}개 지연`;
    }
    get hasBlocked() {
        return (this.fulfillment?.blocked ?? 0) > 0;
    }
    get blockedBadgeLabel() {
        return `지연 ${this.fulfillment?.blocked ?? 0}건 — 해결 시 갱신 명분 강화`;
    }

    // ── 계약 조건(권리) 단위 이행 현황 ──────────────────────────────────
    get hasRights() {
        return (this.fulfillment?.rightsTotal ?? 0) > 0;
    }
    get rightsSummaryLabel() {
        const f = this.fulfillment;
        if (!f || !f.rightsTotal) return null;
        return `계약 조건 이행 ${f.rightsFulfilled}/${f.rightsTotal}건 완료`;
    }
    get rightRows() {
        return (this.fulfillment?.rights || []).map((rt) => {
            let cls = 'su-fx-badge';
            let label;
            if (rt.isFulfilled) { label = '이행 완료'; cls += ' su-fx-badge--done'; }
            else if (rt.hasBlocked) { label = '지연'; cls += ' su-fx-badge--blocked'; }
            else { label = `${rt.completedTasks}/${rt.totalTasks} 진행중`; cls += ' su-fx-badge--progress'; }
            return { key: rt.name, name: rt.name, label, cls };
        });
    }

    get deliverableRows() {
        return (this.fulfillment?.items || []).map((it) => {
            let statusLabel = it.status;
            let statusClass = 'su-fx-badge';
            if (it.isCompleted) { statusLabel = '완료'; statusClass += ' su-fx-badge--done'; }
            else if (it.isBlocked) { statusLabel = '지연'; statusClass += ' su-fx-badge--blocked'; }
            else { statusLabel = it.status || '진행중'; statusClass += ' su-fx-badge--progress'; }
            return {
                key: it.name + (it.dueDate || ''),
                name: it.name,
                statusLabel,
                statusClass,
                weightLabel: (it.weight ?? 0) + '%',
                dueDate: it.dueDate || '–',
                completedDate: it.completedDate || '–',
                blockedReason: it.blockedReason || '',
                evidenceUrl: it.evidenceUrl,
                hasEvidence: !!it.evidenceUrl,
                rowClass: it.isBlocked ? 'su-fx-row su-fx-row--blocked' : 'su-fx-row'
            };
        });
    }
    get deliverableToggleLabel() {
        return this.showDeliverables ? '상세 내역 접기 ▲' : `상세 내역 펼치기 (${this.fulfillment?.total ?? 0}건) ▼`;
    }
    handleToggleDeliverables() {
        this.showDeliverables = !this.showDeliverables;
    }

    // 임의의 실패 값(문자열, DOMException, 일반 Error, Apex AuraHandledException 등)을
    // 사람이 읽을 수 있는 한 줄로 최대한 뽑아낸다.
    _describeError(e) {
        if (e == null) return '(빈 오류 - 세부 정보 없음)';
        if (typeof e === 'string') return e;
        if (e.body && e.body.message) return e.body.message;
        if (e.message) return e.message;
        if (e.name) return e.name;
        try {
            const s = JSON.stringify(e);
            if (s && s !== '{}') return s;
        } catch (jsonErr) {
            // ignore
        }
        try {
            return String(e);
        } catch (strErr) {
            return '(오류 내용을 문자열로 변환하지 못함)';
        }
    }

    // ── PDF 캡처 + Salesforce File 저장 + Slack 발송 ────────────────────
    // Apex/Visualforce가 AccountPlan을 다시 조회·렌더링하지 않도록,
    // 지금 브라우저에 이미 정상 렌더링된 이 패널 DOM을 그대로 캡처해서
    // PDF로 만든다 (html2canvas + jsPDF). 그 결과만 이미 검증된
    // @AuraEnabled 경로로 업로드한다. 각 단계를 개별 try/catch로 감싸서
    // 실패 지점을 토스트 메시지에 정확히 남긴다.
    async handleSendSlack() {
        if (this.sending || !this.recordId) return;
        this.sending = true;
        let step = '라이브러리 로드';
        try {
            await this.ensureLibsLoaded();

            step = '화면 요소 탐색';
            const node = this.template.querySelector('.su-board');
            if (!node) {
                throw new Error('캡처할 화면 요소(.su-board)를 찾지 못했습니다.');
            }
            // eslint-disable-next-line no-undef
            if (typeof html2canvas !== 'function') {
                throw new Error('html2canvas 라이브러리가 로드되지 않았습니다.');
            }
            if (!window.jspdf || typeof window.jspdf.jsPDF !== 'function') {
                throw new Error('jsPDF 라이브러리가 로드되지 않았습니다.');
            }

            step = '화면 캡처(html2canvas)';
            // eslint-disable-next-line no-undef
            const canvas = await html2canvas(node, {
                scale: 2,
                useCORS: true,
                allowTaint: false,
                foreignObjectRendering: false,
                logging: false,
                backgroundColor: '#ffffff'
            });

            step = '이미지 인코딩(toDataURL)';
            const imgData = canvas.toDataURL('image/png');

            step = 'PDF 조립(jsPDF)';
            const { jsPDF } = window.jspdf;
            const pageWidthMm = 210;
            const pageHeightMm = Math.max(1, (canvas.height / canvas.width) * pageWidthMm);
            const doc = new jsPDF({
                orientation: 'portrait',
                unit: 'mm',
                format: [pageWidthMm, pageHeightMm]
            });
            doc.addImage(imgData, 'PNG', 0, 0, pageWidthMm, pageHeightMm);
            const dataUri = doc.output('datauristring');
            const base64Pdf = dataUri.substring(dataUri.indexOf(',') + 1);
            if (!base64Pdf) {
                throw new Error('PDF 데이터가 비어 있습니다.');
            }

            step = 'Salesforce File 저장(saveClientPdf)';
            await saveClientPdf({ recordId: this.recordId, base64Pdf });

            step = 'Slack 발송(sendToSlack)';
            const msg = await sendToSlack({ recordId: this.recordId });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Slack 발송',
                message: msg || '파트너십 업셀 플랜을 Slack으로 발송했습니다.',
                variant: 'success'
            }));
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error('handleSendSlack failed at step:', step, e);
            this.dispatchEvent(new ShowToastEvent({
                title: '발송 실패 (' + step + ')',
                message: this._describeError(e),
                variant: 'error',
                mode: 'sticky'
            }));
        } finally {
            this.sending = false;
        }
    }
}
