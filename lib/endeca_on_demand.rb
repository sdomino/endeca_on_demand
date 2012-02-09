module EndecaOnDemand
end

require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'

require 'builder'
require 'nokogiri'
require 'net/http'
require 'uri'

require 'endeca_on_demand/core_ext'
require 'endeca_on_demand/pp'
require 'endeca_on_demand/proxy'

require 'endeca_on_demand/client'
require 'endeca_on_demand/collection'
require 'endeca_on_demand/query'
require 'endeca_on_demand/response'
require 'endeca_on_demand/version'