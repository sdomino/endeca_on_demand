class EndecaOnDemand
  class SearchReport < Proxy

    require 'endeca_on_demand/search_report/search'
    
    attr_reader :search

    def initialize(search_report)
      search_report.children.each do |node|
        self.instance_variable_set(:"@#{node.name.downcase}", node.content)

        node.xpath("//Search").each do |node|
          @search = EndecaOnDemand::SearchReport::Search.new(node)
        end if node.name == "Search"

        self.class_eval("attr_reader :#{node.name.downcase}")
      end
    end

  end
end
