require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.rails == '<3'
  describe SmartAsset::Adapters::Rails2 do

    include Rack::Test::Methods

    def app
      FrameworkFixture.app.call
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
  end
end