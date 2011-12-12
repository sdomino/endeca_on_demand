module EndecaOnDemand
  class Response
    class AppliedFilters
      class SearchReport
        class Search < EndecaOnDemand::Proxy

          include EndecaOnDemand::PP

          def inspect_attributes; [ :options ]; end

          ## fields ##

          attr_reader :search_report

          def initialize(search_report, xml)
            @search_report, @xml = search_report, xml

            define_getters(:options)
          end

          ## override proxy ##

          def class
            EndecaOnDemand::Response::AppliedFilters::SearchReport::Search
          end

          ##

          ## data ##

          def options
            @options ||= xml.children.inject({}) do |hash,child|
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
end