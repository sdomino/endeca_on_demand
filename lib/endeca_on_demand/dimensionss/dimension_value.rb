class EndecaOnDemand
  class Dimension
  	class DimensionValue < Proxy

    	def initialize(dimension_value)
      	dimension_value.children.each do |node|
          self.instance_variable_set(:"@#{node.name.downcase}", node.content)
          self.class_eval("attr_reader :#{node.name.downcase}")
        end
      end

  	end
  end
end
