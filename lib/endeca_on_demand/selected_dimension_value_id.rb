class EndecaOnDemand::SelectedDimensionValueId < EndecaOnDemand::Proxy

  def initialize(selected_dimension_value_id)
    selected_dimension_value_id.each do |node|
      self.instance_variable_set(:"@#{node.name.downcase}", node.content)
      self.class_eval("attr_reader :#{node.name.downcase}")
    end
  end

end