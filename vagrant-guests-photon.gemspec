# encoding: UTF-8
# Copyright (c) 2015 VMware, Inc. All Rights Reserved.
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'vagrant-guests-photon/version'

Gem::Specification.new do |s|
  s.name = 'vagrant-guests-photon'
  s.version = VagrantPlugins::GuestPhoton::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = 'Fabio Rapposelli'
  s.email = 'fabio@vmware.com'
  s.homepage = 'https://github.com/vmware/vagrant-guests-photon'
  s.license = 'APL2'
  s.summary = 'VMware Photon Guest Plugin for Vagrant'
  s.description = 'Enables Vagrant to manage VMware Photon machines.'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake', '< 11.0'
  s.add_development_dependency 'rspec-core', '~> 2.14'
  s.add_development_dependency 'rspec-expectations', '~> 2.14'
  s.add_development_dependency 'rspec-mocks', '~> 2.14'
  s.add_development_dependency 'rubocop'

  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(/^bin/) { |f| File.basename(f) }
  s.test_files = s.files.grep(/^(test|spec|features)/)
  s.require_path = 'lib'
end
