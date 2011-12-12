module EndecaOnDemand
  class Collection < EndecaOnDemand::Proxy

    attr_reader :klass, :target

    def initialize(klass, target, mapping = nil)
      @klass, @target = klass, target
      @target = target.map { |object| @klass.new(mapping, object) } if mapping.present?
      extend klass.collection_class if klass.respond_to?(:collection_class)
    end

    ## override proxy ##

    def class
      EndecaOnDemand::Collection
    end

    def inspect
      target.to_a.inspect
    end

    ##

    def where(conditions = {})
      target.select do |object|
        conditions.all? do |key,value|
          value.is_a?(Regexp) ? object.send(key) =~ value : object.send(key) == value
        end
      end
    end

    protected

    def wrap_collection(collection)
      EndecaOnDemand::Collection.new(klass, collection)
    end

    def method_missing(name, *args, &block)
      target.send(name, *args, &block)
    end

  end
end