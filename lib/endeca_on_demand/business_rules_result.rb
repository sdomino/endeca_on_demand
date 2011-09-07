class EndecaOnDemand
  class BusinessRulesResult < Proxy
    
    attr_reader :properties

    require 'endeca_on_demand/business_rules_result/property'
    
    def initialize(business_rules_result)
      @properties         = []
      @records            = []
      
      business_rules_result.children.each do |node|

        if node.name == "properties"
          node.xpath("./properties").each do |node|
            @properties.push(EndecaOnDemand::BusinessRulesResult::Property.new(node))
          end
        end

        if node.name == "RecordSet"
          node.xpath("./RecordSet//Record").each do |node|
            @records.push(EndecaOnDemand::Record.new(node))
          end
        end

        self.instance_variable_set(:"@#{node.name.downcase}", node.content)
        self.class_eval("attr_reader :#{node.name.downcase}")
      end
    end
    
  end
end
