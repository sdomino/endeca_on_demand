class EndecaOnDemand
  class Dimension < Proxy

    require 'endeca_on_demand/dimension/dimension_value'
    
    attr_reader :dimension_values
    
    def initialize(dimension)
      @dimension_values = []
      
      dimension.children.each do |node|
        if node.name == "DimensionValues"
          node.xpath("./DimensionValue").each do |node|
            @dimension_values.push(EndecaOnDemand::Dimension::DimensionValue.new(node))
          end
        else
          self.instance_variable_set(:"@#{node.name.downcase}", node.content)
          self.class_eval("attr_reader :#{node.name.downcase}")
        end
      end
    end
    
  end
end
