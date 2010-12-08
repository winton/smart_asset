require 'spec_helper'

unless FrameworkFixture.framework
  describe SmartAsset do
    
    include SmartAsset::Helper
  
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
        SmartAsset.config.should == {
         "asset_host_count"=>2,
         "asset_host"=>{"production"=>"http://assets%d.host.com"},
         "destination"=>{"javascripts"=>"compressed", "stylesheets"=>"compressed"},
         "environments"=>["production"],
         "public"=>"spec/fixtures/assets",
         "sources"=>{"javascripts"=>"javascripts", "stylesheets"=>"stylesheets"},
         "javascripts"=>
          {"package"=>["jquery/jquery", "underscore", "does_not_exist"],
           "empty_package"=>nil,
           "non_existent_package"=>["does_not_exist"]},
         "stylesheets"=>
          {"package"=>["blueprint/blueprint", 960, "does_not_exist"],
           "empty_package"=>nil,
           "non_existent_package"=>["does_not_exist"]}}
      end
      
      it "should populate @asset_host" do
        SmartAsset.asset_host.should == {"production"=>"http://assets%d.host.com"}
      end
    
      it "should populate @dest" do
        SmartAsset.dest.should == {
          'javascripts' => "#{$root}/spec/fixtures/assets/compressed",
          'stylesheets' => "#{$root}/spec/fixtures/assets/compressed"
        }
      end
      
      it "should populate @envs" do
        SmartAsset.envs.should == ["production"]
      end
      
      it "should populate @pub" do
        SmartAsset.pub.should == "#{$root}/spec/fixtures/assets"
      end
      
      it "should populate @root" do
        SmartAsset.root.should == $root
      end
    
      it "should populate @sources" do
        SmartAsset.sources.should == {"javascripts"=>"javascripts", "stylesheets"=>"stylesheets"}
      end
    end
  
    describe :binary do
    
      before(:all) do
        @dest = "#{$root}/spec/fixtures/assets/compressed"
        @old_version = '20101130061252'
        @files = %w(
          package.css
          package.js
        )
        @versions = %w(
          20101130061253
          20101130061253
        )
      end
    
      describe 'no compressed assets' do
      
        before(:all) do
          FileUtils.rm_rf(@dest) unless ENV['FAST']
          @output = capture_stdout do
            SmartAsset.binary $root, @config
          end
        end
    
        it "should generate correct filenames" do
          @files.each_with_index do |file, i|
            File.exists?("#{@dest}/#{@versions[i]}_#{file}").should == true
          end
          Dir["#{@dest}/*"].length.should == @files.length
        end
      
        it "should create package files with content" do
          @files.each_with_index do |file, i|
            File.size(path = "#{@dest}/#{@versions[i]}_#{file}").should > 0
            if i == 0
              css = File.read(path)
              css.include?('.container_12').should == true
              css.include?('.error').should == true
            else
              js = File.read(path)
              js.include?('jQuery').should == true
              js.include?('VERSION').should == true
            end
          end
        end
        
        unless ENV['FAST']
          it "should run all files through the compressor" do
            @files.each do |file|
              @output.string.include?(file).should == true
            end
          end
        end
      end
  
      describe 'one version out of date' do
    
        before(:all) do
          unless ENV['FAST']
            FileUtils.mv "#{@dest}/#{@versions[0]}_#{@files[0]}", "#{@dest}/#{@old_version}_#{@files[0]}"
          end
          @output = capture_stdout do
            SmartAsset.binary $root, @config
          end
        end
  
        it "should generate correct filenames" do
          @files.each_with_index do |file, i|
            File.exists?("#{@dest}/#{@versions[i]}_#{file}").should == true
          end
          Dir["#{@dest}/*"].length.should == @files.length
        end
    
        it "should create package files with content" do
          @files.each_with_index do |file, i|
            File.size(path = "#{@dest}/#{@versions[i]}_#{file}").should > 0
            if i == 0
              css = File.read(path)
              css.include?('.container_12').should == true
              css.include?('.error').should == true
            else
              js = File.read(path)
              js.include?('jQuery').should == true
              js.include?('VERSION').should == true
            end
          end
        end
        
        unless ENV['FAST']
          it "should run updated file through the compressor" do
            @files.each_with_index do |file, i|
              @output.string.include?(file).should == (i == 0 ? true : false)
            end
          end
        end
      end
    end
  
    describe :path do
    
      describe "development" do
        
        before(:all) do
          SmartAsset.env = 'development'
        end
        
        it "should return development paths" do
          SmartAsset.paths('javascripts', :package).should == [
            "/javascripts/jquery/jquery.js",
            "/javascripts/underscore.js"
          ]
          SmartAsset.paths('stylesheets', :package).should == [
            "/stylesheets/blueprint/blueprint.css",
            "/stylesheets/960.css"
          ]
        end
        
        it "should leave @cache empty" do
          SmartAsset.cache.should == {"javascripts"=>{}, "stylesheets"=>{}}
        end
      end
      
      describe "production" do
        
        before(:all) do
          SmartAsset.env = 'production'
        end
        
        it "should return compressed paths" do
          SmartAsset.paths('javascripts', :package).should == [
            "/compressed/20101130061253_package.js"
          ]
          SmartAsset.paths('stylesheets', :package).should == [
            "/compressed/20101130061253_package.css"
          ]
        end
      
        it "should populate @cache" do
          SmartAsset.cache.should == {"javascripts"=>
            {"package"=>["/compressed/20101130061253_package.js"]},
           "stylesheets"=>
            {"package"=>["/compressed/20101130061253_package.css"]}}
        end
      end
    end
    
    describe :helper do
      describe "production" do
        
        before(:all) do
          SmartAsset.env = 'production'
          SmartAsset.asset_counter = nil
        end
        
        before(:each) do
          SmartAsset.cache = nil
        end
        
        it "should output correct script tags" do
          javascript_include_merged(:package, :unknown).split("\n").should == [
            "<script src=\"http://assets0.host.com/compressed/20101130061253_package.js\" type=\"text/javascript\"></script>"
          ]
        end
        
        it "should output correct style tags" do
          stylesheet_link_merged(:package, :unknown).split("\n").should == [
            "<link href=\"http://assets1.host.com/compressed/20101130061253_package.css\" media=\"screen\" rel=\"Stylesheet\" type=\"text/css\" />"
          ]
        end
      end
      
      describe "development" do
        
        before(:all) do
          SmartAsset.env = 'development'
        end
        
        before(:each) do
          SmartAsset.cache = nil
        end
        
        it "should output correct script tags for a package" do
          javascript_include_merged(:package, :unknown).split("\n").should == [
            "<script src=\"/javascripts/jquery/jquery.js\" type=\"text/javascript\"></script>",
            "<script src=\"/javascripts/underscore.js\" type=\"text/javascript\"></script>"
          ]
        end
        
        it "should output correct style tags" do
          stylesheet_link_merged(:package, :unknown, :media => 'print').split("\n").should == [
            "<link href=\"/stylesheets/blueprint/blueprint.css\" media=\"print\" rel=\"Stylesheet\" type=\"text/css\" />",
            "<link href=\"/stylesheets/960.css\" media=\"print\" rel=\"Stylesheet\" type=\"text/css\" />"
          ]
        end
      end
    end
  end
end