class EndecaOnDemand
  class Proxy
    
    def method_missing(method, *args, &block)
      unless self.instance_variables.include?(:"@#{method}")
        "#{method} is unavailable."
      end
    end
    
  end
end