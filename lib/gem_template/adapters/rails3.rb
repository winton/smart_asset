module GemTemplate
  module Adapters
    module Rails3
      
      def self.included(klass)
      end
    end
  end
end

# ActionController::Base.send(:include, GemTemplate)
# ActionController::Base.send(:include, GemTemplate)
# ActionController::Base.helper(GemTemplate)
# ActiveRecord::Base.send(:include, GemTemplate)