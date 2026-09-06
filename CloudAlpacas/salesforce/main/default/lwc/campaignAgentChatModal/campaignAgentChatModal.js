import { LightningElement, api } from 'lwc';
import MASCOT_URL from '@salesforce/resourceUrl/CA_Alpaca_Mascot';

const DAY_FMT = { month: 'long', day: 'numeric' };
const TIME_FMT = { hour: 'numeric', minute: '2-digit', hour12: true };
const PREVIEW_MAX = 60;
const DAY_MS = 24 * 60 * 60 * 1000;

/**
 * Wide Campaign Agent workspace (SLDS modal over the Campaign page).
 * Presentational only — all transport, history and state live in the parent
 * c-campaign-agent-chat. Emits: close, back, openconversation, newconversation,
 * search, send.
 */
export default class CampaignAgentChatModal extends LightningElement {
    @api campaignName;
    @api view = 'list'; // 'list' | 'detail'
    @api conversations = [];
    @api activeConversation;
    @api searchTerm = '';
    @api busy = false;

    mascotUrl = MASCOT_URL;
    followUpDraft = '';
    pendingDeleteId;
    _focused = false;

    renderedCallback() {
        if (this._focused) {
            return;
        }
        this._focused = true;
        try {
            const target =
                this.template.querySelector('.oac-initial-focus') ||
                this.template.querySelector('lightning-textarea, button, [tabindex]');
            if (target && typeof target.focus === 'function') {
                target.focus();
            }
        } catch (e) {
            // focus is a convenience, never fatal
        }
    }

    // --- view flags ------------------------------------------------

    get isListView() {
        return this.view !== 'detail';
    }

    get isDetailView() {
        return this.view === 'detail';
    }

    get headingId() {
        return 'oac-modal-heading';
    }

    // --- list view ------------------------------------------------

    /**
     * Conversations worth showing: at least one real user/agent message. An
     * untouched "새 대화" row carries no meaning in the list, so it is hidden
     * here (the underlying record is never deleted).
     */
    get filteredConversations() {
        const withContent = (this.conversations || []).filter((c) =>
            (c.messages || []).some((m) => m.role === 'user' || m.role === 'agent')
        );
        const term = (this.searchTerm || '').trim().toLowerCase();
        if (!term) {
            return withContent;
        }
        return withContent.filter((c) => {
            if ((c.title || '').toLowerCase().includes(term)) {
                return true;
            }
            return (c.messages || []).some((m) => (m.text || '').toLowerCase().includes(term));
        });
    }

    get hasConversations() {
        return this.filteredConversations.length > 0;
    }

    get groupedConversations() {
        const groups = [];
        const byKey = new Map();
        for (const c of this.filteredConversations) {
            const key = this.dayKey(c.updatedAt);
            if (!byKey.has(key)) {
                const group = { key, label: this.dayLabel(c.updatedAt), items: [] };
                byKey.set(key, group);
                groups.push(group);
            }
            byKey.get(key).items.push(this.toCard(c));
        }
        // gentle emphasis on the most recent conversation
        if (groups.length && groups[0].items.length) {
            groups[0].items[0] = {
                ...groups[0].items[0],
                rowClass: 'oac-convo-row oac-convo-row_featured'
            };
        }
        return groups;
    }

    toCard(c) {
        const visible = (c.messages || []).filter((m) => m.role === 'user' || m.role === 'agent');
        const last = visible.length ? visible[visible.length - 1] : null;
        let preview = last ? last.text.replace(/\s+/g, ' ').trim() : '';
        if (preview.length > PREVIEW_MAX) {
            preview = `${preview.slice(0, PREVIEW_MAX)}…`;
        }
        return {
            id: c.id,
            title: c.title || '새 대화',
            preview: last ? `마지막 대화: "${preview}"` : '',
            time: this.formatTime(c.updatedAt),
            rowClass: 'oac-convo-row'
        };
    }

    // --- detail view --------------------------------------------

    get detailMessages() {
        const msgs = (this.activeConversation && this.activeConversation.messages) || [];
        return msgs.map((m) => ({
            key: m.key,
            text: m.text,
            time: this.formatTime(m.ts),
            isUser: m.role === 'user',
            isMeta: m.role === 'system' || m.role === 'error',
            isError: m.role === 'error',
            rowClass: `oac-row oac-row_${m.role}`
        }));
    }

    get hasDetailMessages() {
        return this.detailMessages.length > 0;
    }

    get followUpDisabled() {
        return this.busy || this.followUpDraft.trim().length === 0;
    }

    get sendClass() {
        return this.followUpDisabled ? 'oac-send oac-send_off' : 'oac-send';
    }

    // --- events -------------------------------------------------

    close() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    back() {
        this.dispatchEvent(new CustomEvent('back'));
    }

    newConversation() {
        this.followUpDraft = '';
        this.dispatchEvent(new CustomEvent('newconversation'));
    }

    openConversation(event) {
        const id = event.currentTarget.dataset.id;
        this.dispatchEvent(new CustomEvent('openconversation', { detail: { id } }));
    }

    // --- delete one saved conversation (localStorage only) ------

    requestDelete(event) {
        event.stopPropagation();
        this.pendingDeleteId = event.currentTarget.dataset.id;
    }

    cancelDelete() {
        this.pendingDeleteId = undefined;
    }

    confirmDelete() {
        const id = this.pendingDeleteId;
        this.pendingDeleteId = undefined;
        if (id) {
            this.dispatchEvent(new CustomEvent('deleteconversation', { detail: { id } }));
        }
    }

    handleConfirmKeydown(event) {
        if (event.key === 'Escape') {
            event.stopPropagation();
            this.cancelDelete();
        }
    }

    handleSearch(event) {
        this.dispatchEvent(new CustomEvent('search', { detail: { value: event.target.value } }));
    }

    handleFollowUpInput(event) {
        this.followUpDraft = event.target.value;
    }

    handleFollowUpKey(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.sendFollowUp();
        }
    }

    sendFollowUp() {
        const text = this.followUpDraft.trim();
        if (!text || this.busy) {
            return;
        }
        this.followUpDraft = '';
        this.dispatchEvent(new CustomEvent('send', { detail: { text } }));
    }

    handleKeyDown(event) {
        if (event.key === 'Escape') {
            event.stopPropagation();
            this.close();
        }
    }

    handleBackdrop() {
        this.close();
    }

    stop(event) {
        event.stopPropagation();
    }

    // --- date helpers ------------------------------------------

    dayKey(ts) {
        try {
            const d = new Date(Number(ts));
            return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`;
        } catch (e) {
            return 'unknown';
        }
    }

    dayLabel(ts) {
        const base = this.formatDay(ts);
        const rel = this.relativeDay(ts);
        return rel ? `${base} (${rel})` : base;
    }

    relativeDay(ts) {
        try {
            const now = new Date();
            const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
            const d = new Date(Number(ts));
            const startOfThat = new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
            const diff = Math.round((startOfToday - startOfThat) / DAY_MS);
            if (diff === 0) {
                return '오늘';
            }
            if (diff === 1) {
                return '어제';
            }
            return '';
        } catch (e) {
            return '';
        }
    }

    formatDay(ts) {
        try {
            return new Date(Number(ts)).toLocaleDateString('ko-KR', DAY_FMT);
        } catch (e) {
            return '';
        }
    }

    formatTime(ts) {
        const n = Number(ts);
        if (!n) {
            return '';
        }
        try {
            return new Date(n).toLocaleTimeString('ko-KR', TIME_FMT);
        } catch (e) {
            return '';
        }
    }
}
