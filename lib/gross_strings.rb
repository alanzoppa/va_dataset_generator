class GrossStrings
    INDEX_URI = "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_rp_800001_condoName%3D1_%26_rp_800001_approvedOnly%3D1_yes%26_rp_800001_condoId%3D1_%26_ps_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_county%3D1_%26_rp_800001_stateCode%3D1_IL%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_performSearchPud%26_st_800001%3Dmaximized%26_rp_800001_reportType%3D1_summary%26_rp_800001_regionalOffice%3D1_%26_rp_800001_city%3D1_CHICAGO&_requestid=811905"
    def self.detail_uri(id)
      "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_pm_800001%3Dview%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_viewPudDetails%26_ps_800001%3Dmaximized%26_st_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_sortLetter%3D1_%26_rp_800001_singledetail%3D1_#{id}&_requestid=816752"
    end
end
