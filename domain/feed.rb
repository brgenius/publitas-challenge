module Domain
  class Feed
    attr_accessor :xml, :item_count

    def initialize(xml, item_count)
      @xml = xml
      @item_count = item_count
    end
    
    def has_valid_itens?
      item_count > 0
    end
  end
end