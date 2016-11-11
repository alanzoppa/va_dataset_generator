
require "va_dataset_generator/version"
require 'uri'
require 'mechanize'
require 'pry'

class VaDatasetGenerator
  attr_accessor :uri, :agent, :detail_ids, :data
  def self.stuff
    puts 'stuff'
  end


  PATTERN = /javascript:void\(setSingleValue\('(.*)'\)\);/
  #URI.encode_www_form("q" => "ruby", "lang" => "en")


  def initialize
    @uri = "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_rp_800001_condoName%3D1_%26_rp_800001_approvedOnly%3D1_yes%26_rp_800001_condoId%3D1_%26_ps_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_county%3D1_%26_rp_800001_stateCode%3D1_IL%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_performSearchPud%26_st_800001%3Dmaximized%26_rp_800001_reportType%3D1_summary%26_rp_800001_regionalOffice%3D1_%26_rp_800001_city%3D1_CHICAGO&_requestid=811905"
    @agent = Mechanize.new
    @page = @agent.get(@uri)

    @refids = []
  
  end

  def headers
    unless defined? @headers
      @headers = @data.map {|d| d.keys}.flatten.uniq
    end
    @headers
  end


  def gather_ids
    @detail_ids = []
    @page.links.each_with_index do |link, index|
      break if index > 50
      if is_detail_page?(link)
        detail_ids << detail_value(link.attributes["href"])
      end
    end
    @detail_ids
  end

  def is_detail_page?(link)
    link.attributes.keys.include?("href") && link.attributes["href"].include?("setSingleValue")
  end

  def detail_value(str)
    str.gsub(PATTERN, '\1')
  end

  def gather_data
    @data = gather_ids.map {|id| get_detail(id) }
    @data
  end

  def get_detail(id)
    puts 'fetching page'
    uri = "https://vip.vba.va.gov/portal/VBAH/VBAHome/condopudsearch?paf_portalId=default&paf_communityId=100002&paf_pageId=500002&paf_dm=full&paf_gear_id=800001&paf_gm=content&paf_ps=_pm_800001%3Dview%26_md_800001%3Dview%26_rp_800001_cpbaction%3D1_viewPudDetails%26_ps_800001%3Dmaximized%26_st_800001%3Dmaximized%26_pid%3D800001%26_rp_800001_sortLetter%3D1_%26_rp_800001_singledetail%3D1_#{id}&_requestid=816752"
    page = @agent.get(uri)
    out = {"id" => id}

    pairs = page.search('table.inputpanelfields tr').map do |tr|
      td_nodes = tr.children.map {|n| n.text.gsub(/\t|\n/, '').strip}
      td_nodes.reject! {|t| t == ""}
      td_nodes
    end

    pairs.each do |k,v|
      out[k] = v
    end

    return out
  end



end
