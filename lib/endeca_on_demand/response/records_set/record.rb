class EndecaOnDemand::Response::RecordsSet::Record < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :properties ]; end

  ## fields ##

  attr_reader :properties, :records_set

  def initialize(records_set, xml)
    @records_set, @xml = records_set, xml

    properties
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::RecordsSet::Record
  end

  ##

  ## associations ##

  def properties
    @properties ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Property, xml.children, self)
  end

  ##

  ## data ##

  def keys
    properties.map { |property| property.name }
  end

  def serializable_hash
    properties.inject({}) { |hash,property| hash.tap { hash[property.name] = property } }.symbolize_keys
  end
  alias :to_hash :serializable_hash

  ##

  protected

  def method_missing(method, *args, &block)
    if @properties.present? and (property = properties.where(label: method.to_s).first || properties.where(name: method.to_s).first).present?
      return property.value
    end
    super(method, *args, &block)
  rescue NoMethodError
    ''
  end

end