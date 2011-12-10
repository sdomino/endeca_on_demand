class EndecaOnDemand::Proxy

  # We undefine most methods to get them sent through to the target.
  instance_methods.each do |method|
    undef_method(method) unless
      method =~ /(^__|^send$|^object_id$|^extend$|^respond_to\?$|^tap$|^inspect$|^pretty_)/
  end

  attr_accessor :xml

  # def inspect
  #   respond_to?(:inspection) ?
  #     "#<#{self.class.name} #{inspection.kind_of?(Hash) ? inspection.inspect : (inspection * ', ')}>" :
  #     super
  # end

  def inspect # :nodoc:
    return super if not respond_to?(:inspect_attributes) or inspect_attributes.blank?
    attributes = inspect_attributes.reject { |x|
      begin
        attribute = send x
        attribute.blank?
      rescue NoMethodError
        true
      end
    }.map { |attribute|
      "#{attribute.to_s.sub(/_\w+/, 's')}=#{send(attribute).inspect}"
    }.join ' '
    "#<#{self.class.name}:#{sprintf("0x%x", object_id)} #{attributes}>"
  end

  # def pretty_inspect
  #   respond_to?(:inspection) ?
  #     "#(#{self.class.name} {\n  #{inspection.pretty_inspect}\n})" :
  #     super
  # end

  # def inspect
  #   inspection = []
  #   inspection.concat(options.dup.delete_if { |k,v| v.blank? }.sort_by(&:first).map { |k,v| "#{k}: #{v.inspect}" })
  #   "#<#{self.class.name} #{inspection * ', '}>"
  # end

  protected

  # Default behavior of method missing should be to delegate all calls
  # to the target of the proxy. This can be overridden in special cases.
  #
  # @param [ String, Symbol ] name The name of the method.
  # @param [ Array ] *args The arguments passed to the method.
  def method_missing(name, *args, &block)
    xml.send(name, *args, &block)
  end

  # def method_missing(method, *args, &block)
  #   unless self.instance_variables.include?(:"@#{method}")
  #     "#{method} is unavailable."
  #   end
  # end
  
end