module EndecaOnDemand
  class Response
    class BusinessRulesResult
      class BusinessRule < EndecaOnDemand::Proxy

        include EndecaOnDemand::PP

        def inspect_attributes; [ :options, :properties, :records_set ]; end

        ## fields ##

        attr_reader :options, :properties, :records_set

        def initialize(records_set, xml)
          @records_set, @xml = records_set, xml

          define_getters(:options)
        end

        ## override proxy ##

        def class
          EndecaOnDemand::Response::BusinessRulesResult::BusinessRule
        end

        ##

        ## associations ##

        def properties
          @properties ||= EndecaOnDemand::Collection.new(EndecaOnDemand::Response::Property, xml.children.css('properties'), self)
        end

        def records_set
          @records_set ||= EndecaOnDemand::Response::RecordsSet.new(self, xml.children.css('RecordsSet'))
        end

        ##

        ## data ##

        def options
          @options ||= xml.xpath('child::node()[not(local-name() = "properties" or local-name() = "RecordsSet")]').inject({}) do |hash,child|
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