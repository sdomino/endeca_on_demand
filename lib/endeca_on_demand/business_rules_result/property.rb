class EndecaOnDemand
  class BusinessRulesResult
	  class Property < Proxy
    
      def initialize(property)
        property.children.each do |node|
          self.instance_variable_set(:"@#{node.name.downcase}", node.content)
          self.class_eval("attr_reader :#{node.name.downcase}")
        end
      end

    end 
  end
end
