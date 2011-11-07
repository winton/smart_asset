require "pp"
require "stringio"

require "bundler/setup"

$root = File.expand_path('../../', __FILE__)

gem('framework_fixture', '0.1.3')
require 'framework_fixture'

FrameworkFixture.generate File.dirname(__FILE__) + '/fixtures'

require 'rack/test'

unless FrameworkFixture.framework
  require "#{$root}/lib/smart_asset"
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