# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "endeca_on_demand/version"

Gem::Specification.new do |s|
  s.name        = "endeca_on_demand"
  s.version     = EndecaOnDemand::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['sdomino']
  s.email       = ['sdomino@pagodabox.com']
  s.homepage    = 'http://github.com/sdomino/endeca_on-demand'
  s.summary     = 'Formerly EndecaXml (endeca_xml), This gem provides an easy way for you to use the Thanx Media, Endeca On-Demand Web API'
  s.description = 'EndecaOnDemand will take a query-string and construct an XML query and send it to an hosted Endeca On-Demand Cluster. It will then parse the response and expose an API for using the response data.'

  s.rubyforge_project = "endeca_on_demand"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec'
  
  s.add_dependency 'nokogiri'
end
