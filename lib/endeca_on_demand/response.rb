class EndecaOnDemand::Response < EndecaOnDemand::Proxy

  ## fields ##
  attr_reader :errors, :query, :result, :xml

  def initialize(query, result)
    @query, @result = query, result
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response
  end

  ##

  ## data ##

  def xml
    @xml ||= Nokogiri::XML.parse(result.body) { |config| config.strict.noblanks }
  end

  ##

  ## flags ##

  def valid?
    errors.blank?
  end

  ##

end