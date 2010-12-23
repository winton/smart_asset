require 'spec_helper'

unless FrameworkFixture.framework
  describe SmartAsset do
    
    include SmartAsset::Helper
  
    before(:all) do
      @config = "spec/fixtures/assets.yml"
      @dest = "#{$root}/spec/fixtures/assets/compressed"
      @files = %w(
        package.css
        package.js
      )
      @versions = %w(
        4c0f7deb
        1042e864
      )
    end
  
    describe :load_config do
    
      before(:all) do
        SmartAsset.env = 'development'
        SmartAsset.load_config($root, @config)
      end
    
      it "should populate @root" do
        SmartAsset.root.should == $root
      end
    
      it "should populate @config" do
        SmartAsset.config.should == {
         "append_random"=>{"development"=>true},
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
      
      it "should populate @append_random" do
        SmartAsset.append_random.should == true
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
          Dir["#{@dest}/*.{js,css}"].length.should == @files.length
        end
      
        it "should create package files with content" do
          @files.each_with_index do |file, i|
            File.size(path = "#{@dest}/#{@versions[i]}_#{file}").should > 0
            if i == 0
              css = File.read(path)
              css.index('.error').should < css.index('.container_12')
              css.include?('.error').should == true
              css.include?('.container_12').should == true
            else
              js = File.read(path)
              js.index('jQuery').should < js.index('VERSION')
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
        
        it "should fix YUI compression issue" do
          File.read("#{@dest}/#{@versions[0]}_#{@files[0]}").include?("screen and (").should == true
        end
      end
      
      describe 'one version out of date' do

        before(:all) do
          unless ENV['FAST']
            FileUtils.mv "#{@dest}/#{@versions[0]}_#{@files[0]}", "#{@dest}/00000000_#{@files[0]}"
          end
          @output = capture_stdout do
            SmartAsset.binary $root, @config
          end
        end

        it "should generate correct filenames" do
          @files.each_with_index do |file, i|
            File.exists?("#{@dest}/#{@versions[i]}_#{file}").should == true
          end
          Dir["#{@dest}/*.{js,css}"].length.should == @files.length
        end

        it "should create package files with content" do
          @files.each_with_index do |file, i|
            File.size(path = "#{@dest}/#{@versions[i]}_#{file}").should > 0
            if i == 0
              css = File.read(path)
              css.index('.error').should < css.index('.container_12')
              css.include?('.error').should == true
              css.include?('.container_12').should == true
            else
              js = File.read(path)
              js.index('jQuery').should < js.index('VERSION')
              js.include?('jQuery').should == true
              js.include?('VERSION').should == true
            end
          end
        end
        
        it "should remove old version" do
          Dir["#{@dest}/*.css"].length.should == 1
        end

        unless ENV['FAST']
          it "should run updated file through the compressor" do
            @files.each_with_index do |file, i|
              @output.string.include?(file).should == (i == 0 ? true : false)
            end
          end
        end
      end
      
      unless ENV['FAST']
        describe 'package changed' do
          
          before(:all) do
            @package_config = SmartAsset.config['javascripts']['package']
            @old_package_path = "#{@dest}/#{@versions[1]}_#{@files[1]}"
            @old_package = File.read(@old_package_path)
          end
          
          after(:all) do
            File.open(@old_package_path, 'w') { |f| f.write(@old_package) }
          end
          
          after(:each) do
            SmartAsset.config['javascripts']['package'] = @package_config
          end
          
          describe 'package order changed' do
        
            before(:all) do
              SmartAsset.config['javascripts']['package'].delete 'underscore'
              SmartAsset.config['javascripts']['package'].unshift 'underscore'
              @output = capture_stdout do
                SmartAsset.compress 'javascripts'
              end
            end
        
            it "should rewrite javascript package with underscore code first" do
              File.size(path = "#{@dest}/91d1e5c5_#{@files[1]}").should > 0
              js = File.read(path)
              js.index('jQuery').should > js.index('VERSION')
              js.include?('jQuery').should == true
              js.include?('VERSION').should == true
            end
        
            it "should run updated file through the compressor" do
              @files.each_with_index do |file, i|
                @output.string.include?(file).should == (i == 1 ? true : false)
              end
            end
            
            it "should remove old version" do
              Dir["#{@dest}/*.js"].length.should == 1
            end
          end
          
          describe 'package child removed' do
        
            before(:all) do
              SmartAsset.config['javascripts']['package'].delete 'underscore'
              @output = capture_stdout do
                SmartAsset.compress 'javascripts'
              end
            end
        
            it "should rewrite javascript package with only jquery" do
              File.size(path = "#{@dest}/b00ce510_#{@files[1]}").should > 0
              js = File.read(path)
              js.include?('jQuery').should == true
              js.include?('VERSION').should == false
            end
        
            it "should run updated file through the compressor" do
              @files.each_with_index do |file, i|
                @output.string.include?(file).should == (i == 1 ? true : false)
              end
            end
            
            it "should remove old version" do
              Dir["#{@dest}/*.js"].length.should == 1
            end
          end
        
          describe 'package removed' do

            before(:all) do
              SmartAsset.config['javascripts'].delete 'package'
              @output = capture_stdout do
                SmartAsset.compress 'javascripts'
              end
            end

            it "should delete the javascript package" do
              Dir["#{@dest}/*.js"].length.should == 0
            end
          end
        
          describe 'untracked file' do
          
            before(:all) do
              @modified = Time.parse('12-01-2010').utc
              ENV['MODIFIED'] = @modified.to_s
              @package = "#{@dest}/0fabe271_#{@files[1]}"
              @untracked = "#{$root}/spec/fixtures/assets/javascripts/untracked.js"
              
              File.open(@untracked, 'w') { |f| f.write("var untracked = true;") }
              SmartAsset.config['javascripts']['package'] << 'untracked'
              
              @output = capture_stdout do
                SmartAsset.compress 'javascripts'
              end
            end
            
            after(:all) do
              ENV.delete 'MODIFIED'
              FileUtils.rm @untracked
              FileUtils.rm @package
            end
            
            it "should create package with default modified time" do
              File.exists?(@package).should == true
            end
            
            it "should create package with untracked file" do
              File.read(@package).include?('var untracked').should == true
            end
            
            it "should remove old version" do
              Dir["#{@dest}/*.js"].length.should == 1
            end
          end
        end
      end
    end
  
    describe :path do
    
      describe "development" do
        
        before(:all) do
          SmartAsset.env = 'development'
          SmartAsset.load_config($root, @config)
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
            "/compressed/#{@versions[1]}_#{@files[1]}"
          ]
          SmartAsset.paths('stylesheets', :package).should == [
            "/compressed/#{@versions[0]}_#{@files[0]}"
          ]
        end
      
        it "should populate @cache" do
          SmartAsset.cache.should == {"javascripts"=>
            {"package"=>["/compressed/#{@versions[1]}_#{@files[1]}"]},
           "stylesheets"=>
            {"package"=>["/compressed/#{@versions[0]}_#{@files[0]}"]}}
        end
      end
    end
    
    describe :helper do
      describe "production" do
        
        before(:all) do
          SmartAsset.env = 'production'
          SmartAsset.asset_counter = nil
          SmartAsset.load_config($root, @config)
        end
        
        before(:each) do
          SmartAsset.cache = nil
        end
        
        it "should output correct script tags" do
          javascript_include_merged(:package, :unknown).split("\n").should == [
            "<script src=\"http://assets0.host.com/compressed/#{@versions[1]}_#{@files[1]}\"></script>"
          ]
        end
        
        it "should output correct style tags" do
          stylesheet_link_merged(:package, :unknown).split("\n").should == [
            "<link href=\"http://assets1.host.com/compressed/#{@versions[0]}_#{@files[0]}\" media=\"screen\" rel=\"stylesheet\" />"
          ]
        end
      end
      
      describe "development" do
        
        before(:all) do
          SmartAsset.env = 'development'
          SmartAsset.load_config($root, @config)
        end
        
        before(:each) do
          SmartAsset.cache = nil
        end
        
        it "should output correct script tags for a package" do
          js = javascript_include_merged(:package, :unknown).split("\n")
          js[0].should =~ /<script src="\/javascripts\/jquery\/jquery\.js\?\d+"><\/script>/
          js[1].should =~ /<script src="\/javascripts\/underscore\.js\?\d+"><\/script>/
        end
        
        it "should output correct style tags" do
          css = stylesheet_link_merged(:package, :unknown, :media => 'print').split("\n")
          css[0].should =~ /<link href="\/stylesheets\/blueprint\/blueprint\.css\?\d+" media="print" rel="stylesheet" \/>/
          css[1].should =~ /<link href="\/stylesheets\/960\.css\?\d+" media="print" rel="stylesheet" \/>/
        end
      end
    end
  end
end