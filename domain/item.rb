module Domain
  class Item
    attr_accessor :description, :title, :id
    
    def initialize(:description, :title, :id)
      @description = description
      @title = title
      @id = id
    end
  end
end