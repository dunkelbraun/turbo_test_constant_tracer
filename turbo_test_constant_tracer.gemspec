require_relative 'lib/turbo_test_constant_tracer/version'

Gem::Specification.new do |spec|
  spec.name          = "turbo_test_constant_tracer"
  spec.version       = TurboTestConstantTracer::VERSION
  spec.authors       = ["Marcos Essindi"]
  spec.email         = ["marcessindi@icloud.com"]

  spec.summary       = "Summary"
  spec.homepage      = "https://github.com/dunkelbraun/turbo_test_constant_tracer"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.14.1"
  spec.add_development_dependency "rake-compiler"

  spec.add_dependency "binding_of_caller"
  spec.add_dependency "turbo_test_events"

  spec.extensions = %w[ext/hash_lookup_with_proxy_ext/extconf.rb]
end
