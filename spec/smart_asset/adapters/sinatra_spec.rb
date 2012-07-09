require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.sinatra
  describe 'Sinatra' do

    include Rack::Test::Methods

    def app
      FrameworkFixture.app.call
    end
    
    before(:all) do
      assets = "#{$root}/spec/fixtures/assets"
      pub = "#{$root}/spec/fixtures/builds/sinatra#{FrameworkFixture.exact_version[0..0]}/public"
      FileUtils.mkdir_p pub
      FileUtils.rm_rf "#{pub}/packaged"
      FileUtils.cp_r "#{assets}/compressed", "#{pub}/packaged"
      FileUtils.rm_rf "#{pub}/javascripts"
      FileUtils.cp_r "#{assets}/javascripts", "#{pub}/javascripts"
      FileUtils.rm_rf "#{pub}/stylesheets"
      FileUtils.cp_r "#{assets}/stylesheets", "#{pub}/stylesheets"
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
    
    describe Sinatra::Base.environment do
      it "should execute helpers correctly" do
        get "/test"
        equals_output(Sinatra::Base.environment, last_response.body)
      end
    end
  end
end