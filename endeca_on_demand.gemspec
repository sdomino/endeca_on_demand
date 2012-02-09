# -*- encoding: utf-8 -*-
require File.expand_path('../lib/endeca_on_demand/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name        = "endeca_on_demand"
  s.version     = EndecaOnDemand::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['sdomino']
  s.email       = ['sdomino@pagodabox.com']
  s.homepage    = 'https://github.com/sdomino/endeca_on_demand'
  s.summary     = 'Formerly EndecaXml (endeca_xml), This gem provides an easy way for you to use the Thanx Media, Endeca On-Demand Web API'
  s.description = 'EndecaOnDemand will take a query-string and construct an XML query and send it to an hosted Endeca On-Demand Cluster. It will then parse the response and expose an API for using the response data.'

  s.rubyforge_project = "endeca_on_demand"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  
  s.add_dependency 'nokogiri'
  s.add_dependency 'builder'
  s.add_dependency 'activesupport', '~> 3.2'
  s.add_dependency 'i18n'
end
