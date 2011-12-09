class EndecaOnDemand::Response::RecordsSet::Record::Property < EndecaOnDemand::Proxy

  ## fields ##

  attr_reader :record

  def initialize(record, xml)
    @record, @xml = record, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::RecordsSet::Record::Property
  end

  def inspection
    [ "#{label}: #{to_s.inspect}" ]
  end

  ##

  ## data ##

  def label
    xml.name.to_s.gsub(/^p_/, '')
  end

  def to_s
    xml.content
  end

  ##

end