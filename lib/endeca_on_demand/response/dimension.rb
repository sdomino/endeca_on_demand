module EndecaOnDemand
  class Response
    class Dimension < EndecaOnDemand::Proxy

      include EndecaOnDemand::PP

      def inspect_attributes; [ :dimension_values, :options ]; end

      ## fields ##

      attr_reader :dimension_values, :options, :response
      
      def initialize(response, xml)
        @response, @xml = response, xml

        define_getters(:options)
      end

      ## override proxy ##

      def class
        EndecaOnDemand::Response::Dimension
      end

      ##

      ## associations ##

      def dimension_values
        @dimension_values ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Dimension::DimensionValue, xml.children.css('DimensionValues > DimensionValue'), self)
      end

      ##

      ## data ##

      def options
        @options ||= xml.xpath('child::node()[not(local-name() = "DimensionValues")]').inject({}) do |hash,child|
            hash.tap do
              hash[child.name] = child.content
            end
          end.symbolize_keys
      end

      ##

    end
  end
end

require 'endeca_on_demand/response/dimension/dimension_value'