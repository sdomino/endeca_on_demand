class EndecaOnDemand
  class Search < Proxy

    def initialize(report)
      report.children.each do |node|
        self.instance_variable_set(:"@#{node.name.downcase}", node.content)
        self.class_eval("attr_reader :#{node.name.downcase}")
      end
    end
    
  end
end
