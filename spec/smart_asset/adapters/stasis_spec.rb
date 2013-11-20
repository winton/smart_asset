require File.expand_path("#{File.dirname(__FILE__)}/../../spec_helper")

if FrameworkFixture.stasis
  describe 'Stasis' do
    
    before(:all) do
      @stasis = FrameworkFixture.app.call
      @build = "#{$root}/spec/fixtures/builds/stasis#{FrameworkFixture.exact_version[0..0]}"
      setup_adapter_build("#{@build}/public", "#{@build}_output")
      SmartAsset.binary @build
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