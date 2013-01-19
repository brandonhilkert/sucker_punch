# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sucker_punch/version'

Gem::Specification.new do |gem|
  gem.name          = "sucker_punch"
  gem.version       = SuckerPunch::VERSION
  gem.authors       = ["Brandon Hilkert"]
  gem.email         = ["brandonhilkert@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"

  gem.add_dependency "celluloid", "> 0.11"
  gem.add_dependency "active_support"
end
