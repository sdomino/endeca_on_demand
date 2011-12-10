class EndecaOnDemand::Response::Dimension::DimensionValue < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :options ]; end

  ## fields ##

  attr_reader :dimension, :options

  def initialize(dimension, xml)
    @dimension, @xml = dimension, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::Dimension::DimensionValue
  end

  # def inspection
  #   options.sort_by(&:first).map { |k,v| "#{k}: #{v.inspect}" }
  # end

  def inspection
    Hash[*options.sort_by(&:first).flatten]
  end

  ##

  ## data ##

  def options
    xml.children.inject({}) do |hash,child|
      hash.tap do
        hash[child.name] = child.content
      end
    end.symbolize_keys
  end

  ##

  protected

  def method_missing(method, *args, &block)
    return options[method] if options.has_key?(method)
    super(method, *args, &block)
  end

end