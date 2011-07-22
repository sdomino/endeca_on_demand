class EndecaOnDemand
  class Search

    def initialize(report)
      report.each do |key, value|
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :key, :mode, :relevancerankingsstrategy, :terms

  end
end
