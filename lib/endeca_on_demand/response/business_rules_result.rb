class EndecaOnDemand::Response::BusinessRulesResult < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :business_rules ]; end

  ## fields ##

  attr_reader :business_rules, :response

  def initialize(response, xml)
    @response, @xml = response, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::BusinessRulesResult
  end

  ##

  ## associations ##

  def business_rules
    @business_rules ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::BusinessRulesResult::BusinessRule, xml.children.css('BusinessRule'), self)
  end

  ##
  
end