module Domain
  class BatchItem
    attr_reader :description, :title, :id
    
    def initialize(description, title, id)
      @description = description
      @title = title
      @id = id
    end
  end
end
