module EndecaOnDemand
  class Response
    class RecordsSet
      class Record < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :properties ]; end

        ## fields ##

        attr_reader :properties, :records_set

        def initialize(records_set, xml)
          @records_set, @xml = records_set, xml

          define_getters(:serializable_hash)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::RecordsSet::Record
        end

        ##

        ## associations ##

        def properties
          @properties ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Property, xml.children, self)
        end

        ##

        ## data ##

        def keys
          properties.map { |property| property.name }
        end

        def serializable_hash
          properties.inject({}) do |hash,property|
            hash.tap do
              hash.has_key?(property.label) ? (hash[property.label] = [*hash[property.label]].push(property.value)) : (hash[property.label] = property.value)
            end
          end.symbolize_keys
        end
        alias :to_hash :serializable_hash

        ##

        protected

        def method_missing(method, *args, &block)
          super(method, *args, &block)
        rescue NoMethodError
          ''
        end

      end
    end
  end
end