# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'goodall/version'

Gem::Specification.new do |spec|
  spec.name          = "goodall"
  spec.version       = Goodall::VERSION
  spec.authors       = ["Matthew Nielsen"]
  spec.email         = ["xunker@pyxidis.org"]
  spec.description   = %q{An easy interface for documenting your API while you
write your tests.}
  spec.summary       = %q{Goodall provides an easy interface for documenting your API while you write your tests. It is compatible with Rspec, Cucumber and test-unit, as well as others. Goodall is named after Jane Goodall who has spent her life observing and documenting the behviour of chimpanzees.}
  spec.homepage      = "http://github.com/xunker/goodall"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "multi_json", ">= 1.7"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.10"
end
