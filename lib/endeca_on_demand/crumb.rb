class EndecaOnDemand
  class Crumb

    def initialize(crumb)
      # puts "CRUMB: #{crumb}"
      crumb.each do |key, value|
        # puts "#{key} | #{value}"
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :name, :original_id, :id

  end
end