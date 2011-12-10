module EndecaOnDemand::PP

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

  def pretty_print pp # :nodoc:
    return super if not respond_to?(:inspect_attributes) or inspect_attributes.blank?
    nice_name = self.class.name
    pp.group(2, "#(#{nice_name}:#{sprintf("0x%x", object_id)} {", '})') do

      pp.breakable
      attrs = inspect_attributes.map { |t|
        [t, send(t)] if respond_to?(t)
      }.compact.find_all { |x|
        x.last.present?
      }

      pp.seplist(attrs) do |v|
        if v.last.class == EndecaOnDemand::Collection
          pp.group(2, "#{v.first} = [", "]") do
            pp.breakable
            pp.seplist(v.last) do |item|
              pp.pp item
            end
          end
        else
          pp.text "#{v.first} = "
          pp.pp v.last
        end
      end
      pp.breakable

    end
  end

end