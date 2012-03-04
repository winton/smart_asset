class SmartAsset
  class Stasis < ::Stasis::Plugin

    REGEX = /.*\.(js|css|coffee|sass|scss|less)/

    before_all :before_all
    before_render :before_render

    def initialize(stasis)
      @stasis = stasis

      SmartAsset.env = stasis.options[:development] ? 'development' : 'production'
      SmartAsset.load_config(@stasis.root)
    end

    def before_all
      SmartAsset.cache = nil
      
      @asset_rendered = false
      @packaged = false

      priority = {}
      priority[REGEX] = 100
      @stasis.controller.priority(priority)
      
      @stasis.controller.helpers do
        include SmartAsset::Helper
      end
    end

    def before_render
      return if @stasis.options[:development] || @stasis.path.nil?
      if @stasis.path =~ REGEX
        @asset_rendered = true
      elsif @asset_rendered && !@packaged
        @packaged = true
        SmartAsset.compress 'javascripts'
        SmartAsset.compress 'stylesheets'
      end
    end
  end
end

Stasis.register(SmartAsset::Stasis)