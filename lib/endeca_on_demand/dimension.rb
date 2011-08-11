class EndecaOnDemand
  class Dimension
    
    def initialize(dimension)
      @dimension_values = []
      
      dimension.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
    attr_reader :dimension_values
    
  end
end
