class EndecaOnDemand::Response::Breadcrumb < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :breads ]; end

  ## fields ##

  attr_reader :response

  def initialize(response, xml)
    @response, @xml = response, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::Breadcrumb
  end

  # def inspection
  #   [ "breads: #{breads.inspect}" ]
  # end

  ##

  ## associations ##

  def breads
    @breads ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Breadcrumb::Bread, xml.children.css('Bread'), self)
  end

  ##
  
end