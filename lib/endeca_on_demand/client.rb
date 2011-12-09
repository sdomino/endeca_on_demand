class EndecaOnDemand::Client

  ## fields ##

  attr_reader :api, :errors, :options, :query, :xml

  def initialize(api, options = {})
    @api, @options = api, options.dup.with_indifferent_access

  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError, OpenURI::HTTPError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Nokogiri::XML::SyntaxError => error
    @errors = error
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Client
  end

  ##

  ## associations ##

  def query(options = {})
    @query = nil if options.present?
    @query ||= EndecaOnDemand::Query.new(self, (self.options[:query] || {}).merge(options))
  end

  ##

end