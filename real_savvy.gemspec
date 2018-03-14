# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'real_savvy/version'

Gem::Specification.new do |spec|
  spec.name          = 'real_savvy'
  spec.version       = RealSavvy::VERSION.join('.')
  spec.authors       = ["Ryan Rauh","Michael Bastos","Andrew Rove"]
  spec.email         = 'andrew@realsavvy.com'

  spec.summary       = %q{RealSavvy API Gem}
  spec.description   = %q{A gem for connecting to RealSavvy V3 API}
  spec.homepage      = 'http://rubygems.org/gems/realsavvy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|gemfiles)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'faraday', ">= 0.8.0"
  spec.add_runtime_dependency 'faraday_middleware', ">= 0.8.0"
  spec.add_runtime_dependency 'jwt', ">= 1.0.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.3"
end
