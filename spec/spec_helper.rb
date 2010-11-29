$root = File.expand_path('../../', __FILE__)
require "#{$root}/lib/smart_asset/gems"

SmartAsset::Gems.require(:spec_first)

require 'framework_fixture'

FrameworkFixture.generate File.dirname(__FILE__) + '/fixtures'
SmartAsset::Gems.require(:spec)

require 'rack/test'

require "#{$root}/lib/smart_asset"
require 'pp'
require 'stringio'

Spec::Runner.configure do |config|
end

# For use with rspec textmate bundle
def debug(object)
  puts "<pre>"
  puts object.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
  puts "</pre>"
end

def capture_stdout
  old = $stdout
  out = StringIO.new
  $stdout = out
  yield
  return out
ensure
  $stdout = old
end