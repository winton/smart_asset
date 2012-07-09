require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.sinatra
  describe 'Sinatra' do

    include Rack::Test::Methods

    def app
      FrameworkFixture.app.call
    end
    
    before(:all) do
      build = "#{$root}/spec/fixtures/builds/sinatra#{FrameworkFixture.exact_version[0..0]}"
      setup_adapter_build("#{build}/public")
      Dir.chdir(build) { `#{$root}/bin/smart_asset` } if SmartAsset.env == :production
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
    
    it "should execute helpers correctly" do
      get "/test"
      equals_output(Sinatra::Base.environment, last_response.body)
    end
  end
end