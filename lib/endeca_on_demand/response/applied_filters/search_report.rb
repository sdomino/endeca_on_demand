module EndecaOnDemand
  class Response
    class AppliedFilters
      class SearchReport < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :options, :search ]; end

        ## fields ##

        attr_reader :applied_filters, :search
        
        def initialize(applied_filters, xml)
          @applied_filters, @xml = applied_filters, xml

          define_getters(:options)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::AppliedFilters::SearchReport
        end

        ##

        ## associations ##

        def search
          @search ||= EndecaOnDemand::Response::AppliedFilters::SearchReport::Search.new(self, xml.children.css('Search'))
        end

        ##

        ## data ##

        def options
          @options ||= xml.xpath('child::node()[not(local-name() = "Search")]').inject({}) do |hash,child|
              hash.tap do
                hash[child.name] = child.content
              end
            end.symbolize_keys
        end

        ##

      end
    end
  end
end

require 'endeca_on_demand/response/applied_filters/search_report/search'