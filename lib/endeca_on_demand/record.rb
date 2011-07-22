class EndecaOnDemand
  class Record

    def initialize(record)
      # puts "RECORD: #{record}"
      record.each do |key, value|
        # puts "#{key} | #{value}"
        self.instance_variable_set(:"@#{key.downcase}", value)
      end
    end
    
    # is there anyway to do this dynamically?
    attr_reader :p_name, :p_category_id, :p_dax_item_number, :p_image, :p_price_retail, :p_price_sale, :p_price_sort, :p_url_detail

  end
end
