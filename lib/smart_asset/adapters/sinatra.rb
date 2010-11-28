class SmartAsset
  module Adapters
    module Sinatra
      
      def self.included(klass)
      end
    end
  end
end

# Sinatra::Base.send(:include, SmartAsset)