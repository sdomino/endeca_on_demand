class EndecaOnDemand::Response::Breadcrumb::Bread < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :options ]; end

  ## fields ##

  attr_reader :breadcrumb

  def initialize(breadcrumb, xml)
    @breadcrumb, @xml = breadcrumb, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::Breadcrumb::Bread
  end

  ##

  ## data ##

  def options
    xml.children.inject({}.with_indifferent_access) do |hash,child|
      hash.tap do
        hash[child.name] = child.content
      end
    end
  end

  ##

  protected

  def method_missing(method, *args, &block)
    return options[method] if options.has_key?(method)
    super(method, *args, &block)
  end
  
end