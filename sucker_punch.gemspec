# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sucker_punch/version'

Gem::Specification.new do |gem|
  gem.name          = "sucker_punch"
  gem.version       = SuckerPunch::VERSION
  gem.authors       = ["Brandon Hilkert"]
  gem.email         = ["brandonhilkert@gmail.com"]
  gem.description   = %q{Asynchronous processing library for Ruby}
  gem.summary       = %q{Sucker Punch is a Ruby asynchronous processing using Celluloid, heavily influenced by Sidekiq and girl_friday.}
  gem.homepage      = "https://github.com/brandonhilkert/sucker_punch"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "pry"

  gem.add_dependency "celluloid", "~> 0.16.0"
end
