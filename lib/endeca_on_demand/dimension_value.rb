class EndecaOnDemand
  class DimensionValue
    
    def initialize(dimension_value)
      dimension_value.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
    def method_missing(method, *args, &block)
      unless self.instance_variables.include?(:"@#{method}")
        "N/A"
      end
    end
    
  end
end
