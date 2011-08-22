class EndecaOnDemand
  class DimensionValue < Proxy
    
    def initialize(dimension_value)
      dimension_value.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
  end
end
