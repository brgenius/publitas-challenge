require 'nokogiri'
require 'concurrent'
require 'concurrent-edge'

BATCH_SIZE = 5

def bytes_to_megabytes (bytes)
  bytes / (1024.0 * 1024.0) 
end

def is_lower_than_batch_size?(bytes)
  bytes_to_megabytes(bytes) <= 5
end

def build_batch_indexes(lower_batch_index, upper_batch_index, batch_size)
  {lower_batch_index: lower_batch_index, upper_batch_index: upper_batch_index, batch_size: batch_size}
end


@doc = Nokogiri::XML.parse(File.read("feed.xml"))
@itens =  @doc.xpath("//rss//channel//item")

puts "Item count ->"
@item_count = @doc.xpath("count(//rss//channel//item)").to_i
puts @item_count

@batch_queue_indexes = []

##

def batch_builder
  lower_batch_index = 0
  current_batch = build_batch_indexes(lower_batch_index, @item_count, nil)

  batch_count = 0 
  while lower_batch_index < @item_count do
    search_batch_size_array = lower_batch_index..@item_count
    search_batch_size_array.bsearch do |i|
      
      batch_search_pattern = "//rss//channel//item[position() >= #{lower_batch_index} and position() <= #{i}]"
      batch_size = @doc.xpath(batch_search_pattern).to_s.bytesize
      is_batch_ready = is_lower_than_batch_size?(batch_size)
      
      puts "Batch from index #{lower_batch_index}-#{i} would be: Size #{bytes_to_megabytes(batch_size)} / #{is_batch_ready}..."
      
      if is_batch_ready then
        @batch_queue_indexes << build_batch_indexes(lower_batch_index, i, batch_size)
        lower_batch_index = i+1
      end
      
      !is_batch_ready
    end

    batch_count += 1
    puts "Batch count #{batch_count} >>>>" 
    p @batch_queue_indexes
  end

end


batch_builder
