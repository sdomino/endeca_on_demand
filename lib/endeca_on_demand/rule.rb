class EndecaOnDemand
  class Rule
    
    def initialize(rule)
      rule.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
      
      @properties_array   = []
      @records            = []
    end
    
    # is there anyway to do this dynamically?
    attr_reader :title, :id, :style, :zone, :recordcount, :recordset, :properties, :properties_array, :records

  end
end
