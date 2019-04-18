# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docbook_status/version'

Gem::Specification.new do |spec|
  spec.name          = 'docbook_status'
  spec.version       = DocbookStatus::VERSION
  spec.authors       = ['Rainer Volz']
  spec.email         = ['dev@textmulch.de']

  spec.summary       = 'DocBook utility showing document structure and word count'
  spec.homepage      = 'http://projekte.textmulch.de/docbook_status/'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir.glob('lib/**/*')
  spec.files         += %w{README.md CHANGELOG.md LICENSE.md}
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'libxml-ruby', '~> 2'
  spec.add_runtime_dependency 'term-ansicolor', '~> 1'
  spec.add_runtime_dependency 'sugar_refinery', '~> 1'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'gem-release', '~> 1.0'
end
