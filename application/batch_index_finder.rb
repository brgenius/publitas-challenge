require './application/byte_utils'
require './domain/batch_index'
require './domain/feed'


module Application
  # What it does:
  #  Searches an index between the current start index ( lower_batch_index ) and the total item count
  #  that has a lower 5MB total string size in bytes, including all item attributes.
  #  The goal here is to find as quick as possible, item indexes from feed that later will be sent to ExternalService
  # 
  # Why it was done this way:
  #  As binary search based on indexes, some batches will not be EXACTLY arround 5mb,
  #  but it's faster than do a sequential search testing each index, formming perfect 5mb batches.
  #  It also relies on Nokogiri gem ability to search inside the xml file by xpath queries 
  
  class BatchIndexFinder
    BATCH_SIZE = 5

    attr_reader :feed

    def initialize(feed)
      @feed = feed  
    end

    # Generates a queue of batch indexes to be extracted later and sent to ExternalService
    def builder()
      batch_indexes_queue = []
      lower_batch_index = 0
      
      batch_count = 0 
      while lower_batch_index < @feed.item_count do
        batch_indexes_metadata = search(lower_batch_index)
        
        batch_indexes_queue << batch_indexes_metadata[:batch_index]
        lower_batch_index = batch_indexes_metadata[:new_lower_batch_index] + 1
            
        batch_count += 1
        puts "Batch count #{batch_count} >>>>" 
        yield batch_indexes_metadata[:batch_index]
      end

      batch_indexes_queue
    end
    
    private

    def search(lower_batch_index)
      (lower_batch_index..@feed.item_count).to_a.bsearch do |i|
        
        batch_search_pattern = "//rss//channel//item[position() >= #{lower_batch_index} and position() <= #{i}]"
        batch_size = @feed.xml.xpath(batch_search_pattern).to_s.bytesize
        is_batch_ready = Application::ByteUtils.is_lower_than_batch_size?(batch_size, BATCH_SIZE)
        
        if is_batch_ready then
          puts "Batch from index #{lower_batch_index}-#{i} will contain approximately #{Application::ByteUtils.to_megabytes(batch_size)} mb ..."
          return {
            batch_index: Domain::BatchIndex.new(lower_batch_index, i, batch_size),
            new_lower_batch_index: i
          }
        end
        
        !is_batch_ready
      end
    end

  end
end