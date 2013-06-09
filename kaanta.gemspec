# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kaanta/version'

Gem::Specification.new do |spec|
  spec.name          = "kaanta"
  spec.version       = Kaanta::VERSION
  spec.authors       = ["Sahil Muthoo"]
  spec.email         = ["sahil.muthoo@gmail.com"]
  spec.description   = %q{A Ruby preforking server}
  spec.summary       = %q{Demonstration of common unix idioms to build a preforking server}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
