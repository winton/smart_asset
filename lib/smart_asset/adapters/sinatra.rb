class SmartAsset
  module Adapters
    module Sinatra
      
      def self.included(klass)
        if klass.environment && klass.root
          SmartAsset.env = klass.environment
          SmartAsset.load_config klass.root
        end
      end
    end
  end
end

Sinatra::Base.send(:include, SmartAsset::Helper)