module EndecaOnDemand
  class Client

    include EndecaOnDemand::PP

    def inspect_attributes; [ :api, :default_options ]; end

    ## fields ##

    attr_reader :api, :default_options, :query

    def initialize(api, default_options = {})
      @api, @default_options = api, default_options.dup.recurse(&:symbolize_keys)
    end

    ## associations ##

    def query(options = {})
      @query = nil if options.present?
      @query ||= EndecaOnDemand::Query.new(self, options)
    end

    ##

  end
end