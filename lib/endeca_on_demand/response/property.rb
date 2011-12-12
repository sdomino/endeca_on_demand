module EndecaOnDemand
  class Response
    class Property < EndecaOnDemand::Proxy

      include EndecaOnDemand::PP

      def inspect_attributes; [ :label, :value ]; end

      def inspect; "#{label}: #{value.inspect}"; end

      ## fields ##

      attr_reader :parent

      def initialize(parent, xml)
        @parent, @xml = parent, xml
      end

      ## override proxy ##

      def class
        EndecaOnDemand::Response::Property
      end

      ##

      ## data ##

      def label
        xml.name.to_s.gsub(/^p_/, '')
      end

      def value
        xml.content
      end
      alias :to_s :value
      alias :to_param :value

      ##

    end
  end
end