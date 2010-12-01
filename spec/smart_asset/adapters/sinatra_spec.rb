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
      unless File.exists?("#{pub}/packaged")
        FileUtils.cp_r "#{assets}/compressed", "#{pub}/packaged"
      end
      unless File.exists?("#{pub}/javascripts/underscore.js")
        FileUtils.cp_r "#{assets}/javascripts/.", "#{pub}/javascripts"
      end
      unless File.exists?("#{pub}/stylesheets/960.css")
        FileUtils.cp_r "#{assets}/stylesheets/.", "#{pub}/stylesheets"
      end
    end
  
    it "should have a pulse" do
      get "/pulse"
      last_response.body.should == '1'
    end
    
    if Sinatra::Base.environment == :development
      describe :development do
        it "should execute helpers correctly" do
          get "/test"
          last_response.body.should == File.read("#{$root}/spec/fixtures/development_output.txt")
        end
      end
    end
    
    if Sinatra::Base.environment == :production
      describe :production do
        it "should execute helpers correctly" do
          get "/test"
          last_response.body.should == File.read("#{$root}/spec/fixtures/production_output.txt")
        end
      end
    end
  end
end