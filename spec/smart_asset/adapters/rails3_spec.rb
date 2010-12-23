require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.rails == '<4'
  describe 'Rails 3' do

    include Rack::Test::Methods

    def app
      FrameworkFixture.app.call
    end
  
    before(:all) do
      assets = "#{$root}/spec/fixtures/assets"
      pub = "#{$root}/spec/fixtures/builds/rails3/public"
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
    
    if Rails.env == 'development'
      describe :development do
        it "should execute helpers correctly" do
          get "/test"
          last_response.body.should == File.read("#{$root}/spec/fixtures/development_output.txt")
        end
      end
    end
    
    if Rails.env == 'production'
      describe :production do
        it "should execute helpers correctly" do
          get "/test"
          last_response.body.should == File.read("#{$root}/spec/fixtures/production_output.txt")
        end
      end
    end
  end
end