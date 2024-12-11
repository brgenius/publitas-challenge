module Domain
  class Feed
    attr_accessor :xml, :item_count

    def initialize(xml, item_count)
      @xml = xml
      @item_count = item_count
    end
  end
end