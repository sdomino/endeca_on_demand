class EndecaOnDemand::Response::AppliedFilters::SelectedDimensionValueId < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :value ]; end

  ## fields ##

  attr_reader :applied_filters

  def initialize(applied_filters, xml)
    @applied_filters, @xml = applied_filters, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::AppliedFilters::SelectedDimensionValueId
  end

  ##

  ## data ##

  def to_s
    xml.content
  end
  alias :value :to_s

  ##
  
end