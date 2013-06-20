# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tree_walker/version'

Gem::Specification.new do |spec|
  spec.name          = "tree_walker"
  spec.version       = TreeWalker::VERSION
  spec.authors       = ["Jerome Cornet"]
  spec.email         = ["jerome.cornet@shopify.com"]
  spec.description   = "Generates an include tree from all rails models associations."
  spec.summary       = "Generates an include tree from all rails models associations"
  spec.homepage      = "https://github.com/Shopify/tree_walker"
  spec.license       = "GPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
