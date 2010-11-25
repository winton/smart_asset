require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if SpecFramework.rails == '<4'
  describe GemTemplate::Adapters::Rails3 do

    include Rack::Test::Methods

    def app
      Rails3::Application
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
  end
end