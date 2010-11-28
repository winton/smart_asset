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
        {"spec/fixtures/assets/javascripts"=>{"package"=>["jquery", "underscore"]}},
       "stylesheets"=>{"spec/fixtures/assets/stylesheets"=>{"package"=>["blueprint", 960]}}}
    end
    
    it "should populate @dest" do
      SmartAsset.dest.should == "#{$root}/spec/fixtures/assets/compressed"
    end
  end
  
  describe :compress do
    
    before(:all) do
      SmartAsset.compress $root, @config
    end
    
    it "should" do
      
    end
  end
end