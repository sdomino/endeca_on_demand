class EndecaOnDemand
  class Dimension
    
    def initialize(dimension)
      @dimension_values = []
      
      dimension.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :name, :id, :group_name, :hasmore, :count, :dimensionvalues, :dimension_values

  end
end
