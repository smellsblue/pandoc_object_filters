# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pandoc_object_filters/version"

Gem::Specification.new do |spec|
  spec.name          = "pandoc_object_filters"
  spec.version       = PandocObjectFilters::VERSION
  spec.authors       = ["Mike Virata-Stone"]
  spec.email         = ["mjstone@on-site.com"]

  spec.summary       = %q{A library for object based pandoc filters.}
  spec.description   = %q{This is a small library for creating pandoc filters using Ruby objects. It is forked from the pandoc-filter gem.}
  spec.homepage      = "https://github.com/smellsblue/pandoc_object_filters"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
