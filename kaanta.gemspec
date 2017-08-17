# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaanta/version'

Gem::Specification.new do |spec|
  spec.name          = 'kaanta'
  spec.version       = Kaanta::VERSION
  spec.authors       = ['Sahil Muthoo']
  spec.email         = ['sahil.muthoo@gmail.com']
  spec.description   = 'A Ruby preforking server'
  spec.summary       = 'Demonstration of common unix idioms to build a preforking server'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
