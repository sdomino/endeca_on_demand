class EndecaOnDemand::SearchReport::Search < EndecaOnDemand::Proxy

  def initialize(search)
    search.children.each do |node|
      self.instance_variable_set(:"@#{node.name.downcase}", node.content)
      self.class_eval("attr_reader :#{node.name.downcase}")
    end
  end

end