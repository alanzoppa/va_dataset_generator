require "spec_helper"
require 'pry'
require 'vcr'
require 'ostruct'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end



describe VaDatasetGenerator do
  it "has a version number" do
    expect(VaDatasetGenerator::VERSION).not_to be nil
  end

  describe "functional methods" do
    before(:all) {
      @link = OpenStruct.new
      @link.attributes = {'href' => "javascript:void(setSingleValue('559791'));"}
    }

    it "can test strings for detail data" do
      expect(VaDatasetGenerator.is_detail_page?(@link)).to eql true
    end

    it "can extract the detail id" do
      expect(VaDatasetGenerator.detail_value(@link.attributes['href'])).to eql '559791'
    end

  end

  context "Fetching VA details", :vcr do
    before(:each) do
      @va = VaDatasetGenerator.new(150)
    end
    #it "should find headers" do
      #allow(@va).to receive(:gather_ids)
      #foo = @va.gather_ids
      #expect(@va).to have_received(:gather_ids)
      #binding.pry
    #end
    it "should be able to fetch a single detail" do
      actual = @va.get_detail('529550')
      reference = {
          "id"=>"529550",
          "Condo Name (ID)"=>"1000 WEST WASHINGTON LOFTS (002357)",
          "Address"=>"1000 W WASHINGTON BLVDCHICAGO IL 60607 COOK ",
          "Status"=>"Accepted Without Conditions",
          "Last Update"=>"Unavailable",
          "Request Received Date"=>"01/08/2015",
          "Review Completion Date"=>"01/26/2015"
        }
      reference.keys.each do |key|
        expect(actual[key]).to eql reference[key]
      end
      expect(actual.keys.sort).to eql reference.keys.sort
    end
  end
end
