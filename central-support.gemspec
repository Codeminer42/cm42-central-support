# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'central/support/version'

Gem::Specification.new do |spec|
  spec.name          = "central-support"
  spec.version       = Central::Support::VERSION
  spec.authors       = ["Fabio Akita"]
  spec.email         = ["boss@akitaonrails.com"]

  spec.summary       = %q{Support library for the Central project}
  spec.description   = %q{Extraction of part of the intelligence behind Central}
  spec.homepage      = "https://github.com/Codeminer-42/central-support"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", ">= 5.1"
  spec.add_runtime_dependency "activerecord", ">= 5.1"
  spec.add_runtime_dependency 'enumerize', "~> 2.0"
  spec.add_runtime_dependency 'transitions', "~> 0.1.9"
  spec.add_development_dependency 'vcr', "~> 1.3.1"
  spec.add_development_dependency 'attachinary', "~> 1.3.1"
end
