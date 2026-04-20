lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/xcconfig/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-xcconfig'
  spec.version       = Fastlane::Xcconfig::VERSION
  spec.author        = 'Sergii Ovcharenko'
  spec.email         = 'sergii@sovcharenko.com'

  spec.summary       = 'Adds 2 actions to fastlane to read and update xcconfig files.'
  spec.homepage      = 'https://github.com/sovcharenko/fastlane-plugin-xcconfig'
  spec.license       = 'MIT'

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.required_ruby_version = '>= 2.7'

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'
end
