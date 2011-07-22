class EndecaOnDemand
  class Crumb

    def initialize(crumb)
      crumb.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :name, :original_id, :id

  end
end