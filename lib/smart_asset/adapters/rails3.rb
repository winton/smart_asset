if Rails.root.nil?
  class SmartAsset
    class SmartAssetRailtie < Rails::Railtie
      initializer "smart_asset_railtie.configure_rails_initialization" do
        SmartAsset.env = Rails.env
        SmartAsset.load_config(Rails.root)
      end
    end
  end
else
  SmartAsset.env = Rails.env
  SmartAsset.load_config(Rails.root)
end

ActionController::Base.send(:include, SmartAsset::Helper)
ActionController::Base.helper(SmartAsset::Helper)