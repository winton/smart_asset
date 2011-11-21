# -*- encoding: utf-8 -*-
root = File.expand_path('../', __FILE__)
lib = "#{root}/lib"

$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "smart_asset"
  s.version     = '0.5.9'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Winton Welsh"]
  s.email       = ["mail@wintoni.us"]
  s.homepage    = "http://github.com/winton/smart_asset"
  s.summary     = %q{Smart asset packaging for Rails, Sinatra, and Stasis}
  s.description = %q{Smart asset packaging for Rails, Sinatra, and Stasis.}

  s.executables = `cd #{root} && git ls-files bin/*`.split("\n").collect { |f| File.basename(f) }
  s.files = `cd #{root} && git ls-files`.split("\n")
  s.require_paths = %w(lib)
  s.test_files = `cd #{root} && git ls-files -- {features,test,spec}/*`.split("\n")

  s.add_development_dependency "framework_fixture"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "rspec", "~> 1.0"
end