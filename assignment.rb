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

def build_batch(lower_batch_index, upper_batch_index)
  {lower_batch_index: lower_batch_index, upper_batch_index: upper_batch_index}
end


@doc = Nokogiri::XML.parse(File.read("feed.xml"))
@itens =  @doc.xpath("//rss//channel//item")

puts "Item count ->"
item_count = @doc.xpath("count(//rss//channel//item)").to_i
puts item_count

lower_batch_index = 0
upper_batch_index = item_count

batch_queue_indexes = []
current_batch = build_batch(lower_batch_index, upper_batch_index)

0..upper_batch_index.bsearch do |i|

  puts "Length count ->"
  
  batch_search_pattern = "//rss//channel//item[position() >= #{lower_batch_index} and position() <= #{upper_batch_index}]"
  batch_size = @doc.xpath(batch_search_pattern).to_s.bytesize
  
  puts batch_size
  batch_is_ready? = is_lower_than_batch_size?(batch_size)

  if batch_is_ready? then
    current_batch.lower_batch_index = lower_batch_index
    current_batch.lower_batch_index = lower_batch_index
    
  end
  
  
end


