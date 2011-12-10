class EndecaOnDemand::Response::AppliedFilters::KeywordRedirect < EndecaOnDemand::Proxy

  include EndecaOnDemand::PP

  def inspect_attributes; [ :options ]; end

  ## fields ##

  attr_reader :applied_filters

  def initialize(applied_filters, xml)
    @applied_filters, @xml = applied_filters, xml
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::AppliedFilters::KeywordRedirect
  end

  ##

  ## data ##

  def options
    @options ||= xml.children.inject({}.with_indifferent_access) do |hash,child|
      hash.tap do
        hash[child.name] = child.content
      end
    end
  end

  ##

  protected

  def method_missing(method, *args, &block)
    return options[method] if @options.present? and options.has_key?(method)
    super(method, *args, &block)
  end

end