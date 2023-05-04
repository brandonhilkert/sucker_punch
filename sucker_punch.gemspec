# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sucker_punch/version'

Gem::Specification.new do |spec|
  spec.name          = "sucker_punch"
  spec.version       = SuckerPunch::VERSION
  spec.authors       = ["Brandon Hilkert"]
  spec.email         = ["brandonhilkert@gmail.com"]
  spec.description   = %q{Asynchronous processing library for Ruby}
  spec.summary       = %q{Sucker Punch is a Ruby asynchronous processing using concurrent-ruby, heavily influenced by Sidekiq and girl_friday.}
  spec.homepage      = "https://github.com/brandonhilkert/sucker_punch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "pry"

  spec.add_dependency "concurrent-ruby", "~> 1.0"

  if spec.respond_to?(:metadata)
    spec.metadata['changelog_uri'] = 'https://github.com/brandonhilkert/sucker_punch/blob/master/CHANGES.md'
    spec.metadata['source_code_uri'] = 'https://github.com/brandonhilkert/sucker_punch'
    spec.metadata['bug_tracker_uri'] = 'https://github.com/brandonhilkert/sucker_punch/issues'
  end
end
