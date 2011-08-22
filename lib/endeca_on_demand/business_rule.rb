class EndecaOnDemand
  class BusinessRule < Proxy
    
    attr_reader :properties_array
    
    def initialize(business_rule)
      @properties_array   = []
      @records            = []
      
      business_rule.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
  end
end
