class EndecaOnDemand
  class DimensionValueId

    def initialize(id)
      id.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :dimensionvalueid

  end
end
