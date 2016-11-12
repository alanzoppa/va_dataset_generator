
require "va_dataset_generator/version"
require 'uri'
require 'mechanize'
require 'pry'

class VaDatasetGenerator
  attr_accessor :uri, :agent, :detail_ids, :data

  PATTERN = /javascript:void\(setSingleValue\('(.*)'\)\);/

  def initialize(limit=nil)
    @uri = "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_rp_800001_condoName%3D1_%26_rp_800001_approvedOnly%3D1_yes%26_rp_800001_condoId%3D1_%26_ps_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_county%3D1_%26_rp_800001_stateCode%3D1_IL%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_performSearchPud%26_st_800001%3Dmaximized%26_rp_800001_reportType%3D1_summary%26_rp_800001_regionalOffice%3D1_%26_rp_800001_city%3D1_CHICAGO&_requestid=811905"
    @agent = Mechanize.new
    @page = @agent.get(@uri)
    @limit = limit

    @refids = []
  
  end

  def headers
    unless defined? @headers
      @headers = @data.map {|d| d.keys}.flatten.uniq
    end
    @headers
  end


  def gather_ids
    unless defined? @detail_ids
      @detail_ids = []
      @page.links.each_with_index do |link, index|
        break if !@limit.nil? && index > @limit
        if VaDatasetGenerator.is_detail_page?(link)
          detail_ids << VaDatasetGenerator.detail_value(link.attributes["href"])
        end
      end
    end
    @detail_ids
  end

  def self.is_detail_page?(link)
    link.attributes.keys.include?("href") && link.attributes["href"].include?("setSingleValue")
  end

  def self.detail_value(str)
    str.gsub(PATTERN, '\1')
  end

  def gather_data
    @data = gather_ids.map {|id| get_detail(id) }
    @data
  end

  def get_detail(id)
     #puts "detail for #{id}"
    # honestly what is this fucked http param with a bunch of other params embedded in it
    uri = "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_pm_800001%3Dview%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_viewPudDetails%26_ps_800001%3Dmaximized%26_st_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_sortLetter%3D1_%26_rp_800001_singledetail%3D1_#{id}&_requestid=816752"

    pairs = @agent.get(uri).search('table.inputpanelfields tr').map do |tr|
      tr.children.map {|n| n.text.gsub(/\t|\n/, '').strip}.reject {|t| t == ""}
    end

    pairs.to_h.merge({"id" => id})
  end



end
