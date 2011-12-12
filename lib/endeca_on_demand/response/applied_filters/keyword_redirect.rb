module EndecaOnDemand
  class Response
    class AppliedFilters
      class KeywordRedirect < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :options ]; end

        ## fields ##

        attr_reader :applied_filters

        def initialize(applied_filters, xml)
          @applied_filters, @xml = applied_filters, xml

          define_getters(:options)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::AppliedFilters::KeywordRedirect
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