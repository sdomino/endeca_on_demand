module EndecaOnDemand
  class Proxy

    # We undefine most methods to get them sent through to the target.
    instance_methods.each do |method|
      undef_method(method) unless
        method =~ /(^__|^send$|^object_id$|^extend$|^respond_to\?$|^tap$|^inspect$|^pretty_|^class_eval$|^method$|^instance_$)/
    end

    attr_accessor :xml

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

    protected

    # Default behavior of method missing should be to delegate all calls
    # to the target of the proxy. This can be overridden in special cases.
    #
    # @param [ String, Symbol ] name The name of the method.
    # @param [ Array ] *args The arguments passed to the method.
    def method_missing(name, *args, &block)
      xml.send(name, *args, &block)
    end

    def define_getters(lookup)
      mod = Module.new
      extend mod
      send(lookup).keys.each do |key|
        safe_key = key.to_s.underscore.parameterize('_')
        mod.class_eval <<-RUBY, __FILE__, __LINE__+1

          def #{safe_key}
            send(#{lookup.inspect})[#{key.inspect}]
          end

        RUBY
      end
    end

  end
end