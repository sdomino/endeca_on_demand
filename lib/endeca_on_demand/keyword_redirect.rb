class EndecaOnDemand
  class KeywordRedirect < Proxy

    def initialize(keyword_redirect)
      keyword_redirect.children.each do |node|
	      self.instance_variable_set(:"@#{node.name.downcase}", node.content)
        self.class_eval("attr_reader :#{node.name.downcase}")
      end
    end
    
  end
end
