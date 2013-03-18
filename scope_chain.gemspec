# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scope_chain/version'

Gem::Specification.new do |gem|
  gem.name          = "scope_chain"
  gem.version       = ScopeChain::VERSION
  gem.authors       = ["Jon Moses"]
  gem.email         = ["jon@burningbush.us"]
  gem.description   = %q{Easy testing of scope usage}
  gem.summary       = %q{Easy testing of scope usage for models}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'mocha'
  gem.add_dependency 'activerecord', '~> 3.1.11'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'
end
