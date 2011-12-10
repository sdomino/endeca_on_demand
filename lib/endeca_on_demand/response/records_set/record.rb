class EndecaOnDemand::Response::RecordsSet::Record < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :properties ]; end

  ## fields ##

  attr_reader :properties, :records_set

  def initialize(records_set, xml)
    @records_set, @xml = records_set, xml
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
    properties.inject({}.with_indifferent_access) { |hash,property| hash.tap { hash[property.name] = property } }
  end
  alias :to_hash :serializable_hash

  ##

  protected

  def method_missing(method, *args, &block)
    if @properties.present? and (property = properties.where(label: method.to_s).first || properties.where(name: method.to_s).first).present?
      return property
    end
    super(method, *args, &block)
  end

end