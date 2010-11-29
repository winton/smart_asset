require 'spec_helper'

describe SmartAsset do
  
  before(:all) do
    @config = "spec/fixtures/assets.yml"
  end
  
  describe :load_config do
    
    before(:all) do
      SmartAsset.load_config($root, @config)
    end
    
    it "should populate @root" do
      SmartAsset.root.should == $root
    end
    
    it "should populate @config" do
      SmartAsset.config.should == {"to"=>"spec/fixtures/assets/compressed",
       "javascripts"=>
        {"spec/fixtures/assets/javascripts"=>
          {"package"=>["jquery", "underscore", "does_not_exist"],
           "empty_package"=>nil,
           "non_existent_package"=>["does_not_exist"]}},
       "stylesheets"=>
        {"spec/fixtures/assets/stylesheets"=>
          {"package"=>["blueprint", 960, "does_not_exist"],
           "empty_package"=>nil,
           "non_existent_package"=>["does_not_exist"]}}}
    end
    
    it "should populate @dest" do
      SmartAsset.dest.should == "#{$root}/spec/fixtures/assets/compressed"
    end
  end
  
  describe :binary do
    
    before(:all) do
      @dest = "#{$root}/spec/fixtures/assets/compressed"
      @version = '20101128112833'
      @old_version = '20101128112832'
      @files = %w(
        package.css
        package.js
        spec_fixtures_assets_javascripts_jquery.js
        spec_fixtures_assets_javascripts_underscore.js
        spec_fixtures_assets_stylesheets_960.css
        spec_fixtures_assets_stylesheets_blueprint.css
      )
    end
    
    describe 'no compressed assets' do
      
      before(:all) do
        FileUtils.rm_rf @dest
        @output = capture_stdout do
          SmartAsset.binary $root, @config
        end
      end
    
      it "should generate correct filenames" do
        @files.each do |file|
          File.exists?("#{@dest}/#{@version}_#{file}").should == true
        end
        Dir["#{@dest}/*"].length.should == 6
      end
      
      it "should generate correct file sizes" do
        @files.each do |file|
          File.new("#{@dest}/#{@version}_#{file}").size.should > 0
        end
        total = 0
        @files[2..3].each do |file|
          total += File.new("#{@dest}/#{@version}_#{file}").size
        end
        total.should == File.new("#{@dest}/#{@version}_#{@files[1]}").size
        total = 0
        @files[4..5].each do |file|
          total += File.new("#{@dest}/#{@version}_#{file}").size
        end
        total.should == File.new("#{@dest}/#{@version}_#{@files[0]}").size
      end
      
      it "should run all files through the compressor" do
        @files[2..5].each do |file|
          @output.string.include?(file.split('_')[-1]).should == true
        end
      end
    end
    
    describe 'one version out of date' do
      
      before(:all) do
        FileUtils.mv "#{@dest}/#{@version}_#{@files[2]}", "#{@dest}/#{@old_version}_#{@files[2]}"
        @output = capture_stdout do
          SmartAsset.binary $root, @config
        end
      end
    
      it "should generate correct filenames" do
        @files.each do |file|
          File.exists?("#{@dest}/#{@version}_#{file}").should == true
        end
        Dir["#{@dest}/*"].length.should == 6
      end
      
      it "should generate correct file sizes" do
        @files.each do |file|
          File.new("#{@dest}/#{@version}_#{file}").size.should > 0
        end
        total = 0
        @files[2..3].each do |file|
          total += File.new("#{@dest}/#{@version}_#{file}").size
        end
        total.should == File.new("#{@dest}/#{@version}_#{@files[1]}").size
        total = 0
        @files[4..5].each do |file|
          total += File.new("#{@dest}/#{@version}_#{file}").size
        end
        total.should == File.new("#{@dest}/#{@version}_#{@files[0]}").size
      end
      
      it "should run updated file through the compressor" do
        @files[2..5].each_with_index do |file, i|
          @output.string.include?(file.split('_')[-1]).should == (i == 0 ? true : false)
        end
      end
    end
  end
end