module EndecaOnDemand
  class Response < EndecaOnDemand::Proxy

    include EndecaOnDemand::PP

    def inspect_attributes; [ :applied_filters, :breadcrumbs, :business_rules_result, :dimensions, :keyword_redirects, :records_set ]; end

    ## fields ##
    attr_reader :errors, :query, :result, :xml

    def initialize(query, result)
      @query, @result = query, result
    end

    ## override proxy ##

    def class
      EndecaOnDemand::Response
    end

    ##

    ## associations ##

    def records_set
      @records_set ||= EndecaOnDemand::Response::RecordsSet.new(self, xml.root.children.css('RecordsSet'))
    end

    def breadcrumbs
      @breadcrumbs ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Breadcrumb, xml.root.children.css('Breadcrumbs > Breads'), self)
    end

    def dimensions
      @dimensions ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Dimension, xml.root.children.css('Dimensions > Dimension'), self)
    end

    def business_rules_result
      @business_rules_result ||= EndecaOnDemand::Response::BusinessRulesResult.new(self, xml.root.children.css('BusinessRulesResult > BusinessRules'))
    end

    def applied_filters
      @applied_filters ||= EndecaOnDemand::Response::AppliedFilters.new(self, xml.root.children.css('AppliedFilters'))
    end

    def keyword_redirects
      @keyword_redirects ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::KeywordRedirects, xml.root.children.css('KeywordRedirects'), self)
    end

    ##

    ## data ##

    def xml
      @xml ||= Nokogiri::XML.parse(result.body) { |config| config.strict.noblanks }
    end

    ##

    ## flags ##

    def valid?
      errors.blank?
    end

    ##

  end
end

require 'endeca_on_demand/response/applied_filters'
require 'endeca_on_demand/response/breadcrumb'
require 'endeca_on_demand/response/business_rules_result'
require 'endeca_on_demand/response/dimension'
require 'endeca_on_demand/response/keyword_redirect'
require 'endeca_on_demand/response/property'
require 'endeca_on_demand/response/records_set'