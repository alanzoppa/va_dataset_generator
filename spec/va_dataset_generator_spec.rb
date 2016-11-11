require "spec_helper"
require 'pry'

describe VaDatasetGenerator do
  it "has a version number" do
    expect(VaDatasetGenerator::VERSION).not_to be nil
  end

  it "does something useful" do
    va = VaDatasetGenerator.new
    va.gather_ids
    va.gather_data
    binding.pry
    #id = va.detail_ids[0]
    #va.get_detail(va.detail_page_uri(id))
  end
end
