require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.stasis
  describe 'Stasis' do
    
    before(:all) do
      @stasis = FrameworkFixture.app.call
      assets = "#{$root}/spec/fixtures/assets"
      @build = "#{$root}/spec/fixtures/builds/stasis#{FrameworkFixture.exact_version[0..0]}"
      FileUtils.mkdir_p "#{@build}/public"
      FileUtils.mkdir_p "#{@build}_output"
      FileUtils.rm_rf "#{@build}_output/packaged"
      FileUtils.rm_rf "#{@build}/public/javascripts"
      FileUtils.cp_r "#{assets}/javascripts", "#{@build}/public/javascripts"
      FileUtils.rm_rf "#{@build}/public/stylesheets"
      FileUtils.cp_r "#{assets}/stylesheets", "#{@build}/public/stylesheets"
    end
    
    %w(production development).each do |env|
      it "should execute helpers correctly in #{env}" do
        @stasis.options[:development] = env == 'development'
        @stasis.render
        equals_output(env, File.read("#{@build}_output/test.html"))
      end
    end
  end
end