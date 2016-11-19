
require 'gross_strings'
require "va_dataset_generator/version"
require 'uri'
require 'mechanize'
require 'csv'
require 'pry'

class VaDatasetGenerator
  attr_accessor :uri, :agent, :detail_ids, :data, :page

  PATTERN = /javascript:void\(setSingleValue\('(.*)'\)\);/

  def initialize(limit=nil)
    @agent = Mechanize.new
    @page = @agent.get(GrossStrings::INDEX_URI)
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
          @detail_ids << [
              VaDatasetGenerator.detail_value(link.attributes["href"]),
              link.node.parent.parent.children[-4].text.strip
          ]
        end
      end
    end
    @detail_ids
  end

  def self.is_detail_page?(link)
    link.attributes.keys.include?("href") &&
      link.attributes["href"].include?("setSingleValue")
  end

  def self.detail_value(str)
    str.gsub(PATTERN, '\1')
  end

  def gather_data
    @data = gather_ids.map {|link_id, id| get_detail(link_id, id) }
    @data
  end

  def get_detail(link_id, id)
     #puts "detail for #{id}"
    # honestly what is this fucked http param with a bunch of other params
    # embedded in it

    uri = GrossStrings.detail_uri(link_id)
    pairs = @agent.get(uri).search('table.inputpanelfields tr').map do |tr|
      tr.children.map {|n| n.text.gsub(/\t|\n/, '').strip}.reject {|t| t == ""}
    end
    pairs.to_h.merge({"id" => id})
  end

  def to_csv
    csv_string = CSV.generate do |csv|
      csv << headers
      @data.each do |detail|
        csv << headers.map {|header| detail[header]}
      end
    end
    return csv_string
  end



end
