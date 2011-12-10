class EndecaOnDemand::Response::Property < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :label, :value ]; end

  ## fields ##

  attr_reader :parent

  def initialize(parent, xml)
    @parent, @xml = parent, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::Property
  end

  ##

  ## data ##

  def label
    xml.name.to_s.gsub(/^p_/, '')
  end

  def to_s
    xml.content
  end
  alias :value :to_s

  ##

end