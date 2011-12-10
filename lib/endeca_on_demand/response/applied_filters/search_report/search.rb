class EndecaOnDemand::Response::AppliedFilters::SearchReport::Search < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :options ]; end

  ## fields ##

  attr_reader :search_report

  def initialize(search_report, xml)
    @search_report, @xml = search_report, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::AppliedFilters::SearchReport::Search
  end

  ##

  ## data ##

  def options
    @options ||= xml.children.inject({}) do |hash,child|
        hash.tap do
          hash[child.name] = child.content
        end
      end.symbolize_keys
  end

  ##

  protected

  def method_missing(method, *args, &block)
    return options[method] if @options.present? and options.has_key?(method)
    super(method, *args, &block)
  end

end