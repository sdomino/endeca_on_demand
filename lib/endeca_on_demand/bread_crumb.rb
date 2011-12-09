class EndecaOnDemand::BreadCrumb < EndecaOnDemand::Proxy

  def initialize(bread_crumb)
    bread_crumb.children.each do |node|
      self.instance_variable_set(:"@#{node.name.downcase}", node.content)
      self.class_eval("attr_reader :#{node.name.downcase}")
    end
  end
  
end