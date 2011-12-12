module EndecaOnDemand
  class Response
    class Dimension
      class DimensionValue < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :options ]; end

        ## fields ##

        attr_reader :dimension, :options

        def initialize(dimension, xml)
          @dimension, @xml = dimension, xml

          define_getters(:options)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::Dimension::DimensionValue
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