class Freya::Faceting
  attr_accessor :response
  
  def initialize response
    @response = response
  end
  
  def self.from_hash response
    new(response).faceted
  end
  
  def faceted
    @faceted ||= facet_fields.collect do |field_name, values|
      to_faceted_item(field_name, faceted_items(values))
    end
  end

  class Item
    attr_accessor :value, :object

    def initialize value, object
      @value, @object = value, object
    end
    alias_method :hits, :object
    alias_method :items, :object
  end
      
  private
    
    def to_faceted_item value, object
      Item.new value, object
    end
    
    def faceted_items array, step = 2
      array.each_slice(step).collect do |arr|
        to_faceted_item(arr.first, arr.last)
      end
    end
    
    def facet_counts
      @facet_counts ||= @response['facet_counts'] || {}
    end

    def facet_fields
      @facet_fields ||= facet_counts['facet_fields'] || {}
    end

    def facet_queries
      @facet_queries ||= facet_counts['facet_queries'] || {}
    end

end