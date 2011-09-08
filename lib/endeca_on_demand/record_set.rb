class EndecaOnDemand
  class Record < Proxy

    require 'endeca_on_demand/record_set/record'
    
    attr_reader :records
    
    def initialize(record_set)
      @records = []
      
      record_set.children.each do |node|
        if node.name == "Record"
          node.xpath("./Record").each do |node|
            @records.push(EndecaOnDemand::RecordSet::Record.new(node))
          end
        else
          self.instance_variable_set(:"@#{node.name.downcase}", node.content)
          self.class_eval("attr_reader :#{node.name.downcase}")
        end
      end
    end
    
  end
end
