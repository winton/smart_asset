require "pp"
require "stringio"

require "bundler/setup"
require "stasis"

$root = File.expand_path('../../', __FILE__)

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

def equals_output(type, output)
  output = output.gsub("\n", '')
  output.should == File.read("#{$root}/spec/fixtures/#{type}_output.txt").gsub("\n", '')
end

def setup_adapter_build(source, destination=source)
  assets = "#{$root}/spec/fixtures/assets"
  FileUtils.mkdir_p source
  FileUtils.mkdir_p destination
  FileUtils.rm_rf "#{destination}/packaged"
  FileUtils.rm_rf "#{source}/javascripts"
  FileUtils.cp_r "#{assets}/javascripts", "#{source}/javascripts"
  FileUtils.rm_rf "#{source}/stylesheets"
  FileUtils.cp_r "#{assets}/stylesheets", "#{source}/stylesheets"
end