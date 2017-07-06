# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opsconsole/version'

Gem::Specification.new do |spec|
  spec.name = 'opsconsole'
  spec.version = Opsconsole::VERSION
  spec.authors = ['Rafal Mierzwiak']
  spec.email = ['rm@rm.pl']

  spec.summary = <<-EOS
  Remote terminal multiplexer.
  EOS
  spec.description = <<-EOS
  Handy tool for server operators. Uses SSH to access remote hosts and execute commands on them. Uses tmux to present a consolidated console showing remote hosts terminals and allow for simultaneous interaction with the remote hosts.
  EOS
  spec.homepage = 'https://gitlab.com/rafalmierzwiak/opsconsole'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = 'bin'
  spec.executables = 'opsconsole'

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency('gli', '2.16.0')
end
