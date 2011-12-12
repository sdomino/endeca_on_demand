module EndecaOnDemand
  class Response
    class Breadcrumb
      class Bread < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :options ]; end

        ## fields ##

        attr_reader :breadcrumb

        def initialize(breadcrumb, xml)
          @breadcrumb, @xml = breadcrumb, xml

          define_getters(:options)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::Breadcrumb::Bread
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