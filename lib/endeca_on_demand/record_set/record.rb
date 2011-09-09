class EndecaOnDemand
  class RecordSet
  	class Record < Proxy

      def initialize(record)
        record.children.each do |node|
          self.instance_variable_set(:"@#{node.name.downcase}", node.content)
          self.class_eval("attr_reader :#{node.name.downcase}")
        end
      end
    
    end
  end
end
