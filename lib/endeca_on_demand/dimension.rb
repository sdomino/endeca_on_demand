class EndecaOnDemand
  class Dimension < Proxy
    
    attr_reader :dimension_values
    
    def initialize(dimension)
      @dimension_values = []
      
      dimension.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
        self.class_eval("attr_reader :#{key.downcase}")
      end
    end
    
  end
end
