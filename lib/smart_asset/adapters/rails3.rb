SmartAsset.env = Rails.env
SmartAsset.load_config(Rails.root)

ActionController::Base.send(:include, SmartAsset::Helper)
ActionController::Base.helper(SmartAsset::Helper)