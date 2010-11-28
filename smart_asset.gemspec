# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'smart_asset/gems'
require 'smart_asset/version'

Gem::Specification.new do |s|
  s.name = "smart_asset"
  s.version = SmartAsset::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Winton Welsh"]
  s.email = ["mail@wintoni.us"]
  s.homepage = "http://github.com/winton/smart_asset"
  s.summary = ""
  s.description = ""

  SmartAsset::Gems::TYPES[:gemspec].each do |g|
    s.add_dependency g.to_s, SmartAsset::Gems::VERSIONS[g]
  end
  
  SmartAsset::Gems::TYPES[:gemspec_dev].each do |g|
    s.add_development_dependency g.to_s, SmartAsset::Gems::VERSIONS[g]
  end

  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.executables = Dir.glob("{bin}/*").collect { |f| File.basename(f) }
  s.require_path = 'lib'
end