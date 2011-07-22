class EndecaOnDemand
  class Dimension
    
    def initialize(dimension)
      # puts "DIMENSION: #{dimension}"
      dimension.each do |key, value|
        # puts "#{key} | #{value}"
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
      
      @dimension_values = []
    end
    
    # is there anyway to do this dynamically?
    attr_reader :name, :id, :group_name, :hasmore, :count, :dimensionvalues, :dimension_values

  end
end
