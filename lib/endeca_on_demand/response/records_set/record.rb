class EndecaOnDemand::Response::RecordsSet::Record < EndecaOnDemand::Proxy

  ## fields ##

  attr_reader :properties, :records_set

  def initialize(records_set, xml)
    @records_set, @xml = records_set, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::RecordsSet::Record
  end

  def inspection
    serializable_hash.sort_by(&:first).map { |k,v| v.inspection }
  end

  ##

  ## associations ##

  def properties
    @properties ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::RecordsSet::Record::Property, xml.children.map do |property|
      EndecaOnDemand::Response::RecordsSet::Record::Property.new(self, property)
    end)
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
    if (property = properties.where(label: method.to_s).first || properties.where(name: method.to_s).first).present?
      return property
    end
    super(method, *args, &block)
  end

end