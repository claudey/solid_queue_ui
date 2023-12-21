# frozen_string_literal: true

require_relative "lib/solid_queue_ui/version"

Gem::Specification.new do |spec|
  spec.name = "solid_queue_ui"
  spec.version = SolidQueueUi::VERSION
  spec.authors = ["Claude Ayitey"]
  spec.email = ["code@ayitey.me"]

  spec.summary = "A user interface for the solid_queue gem."
  spec.description = "this plugin provides a user interface to the recently-released solid_queue gem which is a backend for handing jobs in Rails apps."
  spec.homepage = "https://github.com/claudey/solid_queue_ui"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["source_code_uri"] = "https://github.com/claudey/solid_queue_ui"
  spec.metadata["changelog_uri"] = "https://github.com/claudey/solid_queue_ui/changelog.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "solid_queue"
  spec.add_dependency "activerecord", ">= 6.0", "< 8.0"
  spec.add_dependency "sassc-rails", "~> 2.1"


  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
