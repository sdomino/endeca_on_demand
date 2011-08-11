class EndecaOnDemand
  class BusinessRuleProperty
    
    def initialize(property)
      property.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end

  end
end
