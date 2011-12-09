class EndecaOnDemand::Response::RecordsSet < EndecaOnDemand::Proxy

  ## fields ##

  attr_reader :records, :response

  def initialize(response, xml)
    @response, @xml = response, xml
    # @records = []

    # record_set.children.each do |node|
    #   if node.name == "Record"
    #     node.xpath("./Record").each do |node|
    #       @records.push(EndecaOnDemand::RecordSet::Record.new(node))
    #     end
    #   else
    #     self.instance_variable_set(:"@#{node.name.downcase}", node.content)
    #     self.class_eval("attr_reader :#{node.name.downcase}")
    #   end
    # end
  end

  ## override proxy ##

  def class
    EndecaOnDemand::Response::RecordsSet
  end

  def inspection
    options.sort_by(&:first).map { |k,v| "#{k}: #{v.inspect}" }
  end

  ##

  ## associations ##

  def records
    @records ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::RecordsSet::Record, xml.xpath('//Record').map do |record|
      EndecaOnDemand::Response::RecordsSet::Record.new(self, record)
    end)
  end

  ##

  ## data ##

  def options
    xml.xpath('child::node()[not(local-name() = "Record")]').inject({}.with_indifferent_access) do |hash,child|
      hash.tap do
        hash[child.name] = child.content
      end
    end
  end

  ##

  protected

  def method_missing(method, *args, &block)
    return options[method] if options.has_key?(method)
    super(method, *args, &block)
  end
    
end