require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if SpecFramework.sinatra
  describe GemTemplate::Adapters::Sinatra do

    include Rack::Test::Methods

    def app
      Application.new
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
  end
end