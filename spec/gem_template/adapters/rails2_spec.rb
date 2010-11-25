require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if SpecFramework.rails == '<3'
  describe GemTemplate::Adapters::Rails2 do

    include Rack::Test::Methods

    def app
      ActionController::Dispatcher.new
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
  end
end