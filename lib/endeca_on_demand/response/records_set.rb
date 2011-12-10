class EndecaOnDemand::Response::RecordsSet < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :options, :records ]; end

  ## fields ##

  attr_reader :parent, :records

  def initialize(parent, xml)
    @parent, @xml = parent, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::RecordsSet
  end

  ##

  ## associations ##

  def records
    @records ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::RecordsSet::Record, xml.children.css('Record'), self)
  end

  ##

  ## data ##

  def options
    xml.xpath('child::node()[not(local-name() = "Record")]').inject({}) do |hash,child|
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