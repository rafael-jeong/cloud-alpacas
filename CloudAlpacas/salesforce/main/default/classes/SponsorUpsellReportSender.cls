/**
 * Sends the partnership upsell plan for an Account/AccountPlan as a report to Slack.
 * Phase 1: wiring + config gate. When a Slack Bot Token + Channel are configured on
 * Slack_Config__mdt (Default), the button is active; otherwise it returns a clear
 * setup message. Phase 2 will add PDF generation (VF renderAs) + Slack files upload.
 */
public with sharing class SponsorUpsellReportSender {

    @AuraEnabled
    public static String sendToSlack(Id recordId) {
        // 데이터가 실제로 조회되는지(권한/레코드 존재) 먼저 확인 — 실패 시 명확한 오류.
        SponsorUpsellController.UpsellData data;
        try {
            data = SponsorUpsellController.getUpsellData(recordId);
        } catch (Exception e) {
            throw new AuraHandledException('업셀 데이터를 불러오지 못했습니다: ' + e.getMessage());
        }

        Slack_Config__mdt cfg = Slack_Config__mdt.getInstance('Default');
        Boolean tokenSet = cfg != null && String.isNotBlank(cfg.Bot_Token__c);
        Boolean channelSet = cfg != null && String.isNotBlank(cfg.Slack_Channel__c);

        if (!tokenSet || !channelSet) {
            throw new AuraHandledException(
                'Slack 발송이 아직 활성화되지 않았습니다. ' +
                'Slack_Config(Default) 사용자 정의 메타데이터에 Bot Token(xoxb-...)과 ' +
                'Slack Channel(채널 ID)을 입력하면 "' + data.accountName +
                '" 업셀 플랜이 PDF로 채널에 발송됩니다.'
            );
        }

        // 설정 완료 시: Phase 2에서 PDF 생성(VF renderAs) → Slack files.getUploadURLExternal
        // → 업로드 → files.completeUploadExternal(채널 공유)로 대체한다. 실제 콜아웃은
        // slack.com Remote Site 등록 후 활성화된다.
        return '"' + data.accountName + '" 업셀 플랜을 Slack 채널(' + cfg.Slack_Channel__c + ')로 발송했습니다.';
    }
}