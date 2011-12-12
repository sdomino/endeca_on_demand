module EndecaOnDemand
  class Response
    class AppliedFilters
      class SelectedDimensionValueId < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :value ]; end

        ## fields ##

        attr_reader :applied_filters

        def initialize(applied_filters, xml)
          @applied_filters, @xml = applied_filters, xml
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::AppliedFilters::SelectedDimensionValueId
        end

        ##

        ## data ##

        def value
          xml.content
        end
        alias :to_s :value

        ##
        
      end
    end
  end
end