class EndecaOnDemand
  class BusinessRule
    
    def initialize(business_rule)
      @properties_array   = []
      @records            = []
      
      business_rule.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
    attr_reader :properties_array
    
  end
end
