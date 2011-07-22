class EndecaOnDemand
  class SearchReport

    def initialize(report)
      # puts "REPORT: #{report}"
      report.each do |key, value|
        # puts "#{key} | #{value}"
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :none

  end
end
