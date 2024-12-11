require 'concurrent'
require 'concurrent-edge'

require 'nokogiri'
require 'oj'

require './external_service'

BATCH_SIZE = 5

#util

def bytes_to_megabytes (bytes)
  bytes / (1024.0 * 1024.0) 
end

def is_lower_than_batch_size?(bytes)
  bytes_to_megabytes(bytes) <= 5
end

## factories

def batch_index_factory(lower_batch_index, upper_batch_index, batch_size)
  {lower_batch_index: lower_batch_index, upper_batch_index: upper_batch_index, batch_size: batch_size}
end

def xml_node_text_extractor(node, prop)
  item = node.xpath(prop).children.first
  item.nil? ? "" : item.text
end

## services

def batch_index_search(xml_feed, lower_batch_index, item_count)
  (lower_batch_index..item_count).to_a.bsearch_index do |i|
    
    batch_search_pattern = "//rss//channel//item[position() >= #{lower_batch_index} and position() <= #{i}]"
    batch_size = xml_feed.xpath(batch_search_pattern).to_s.bytesize
    is_batch_ready = is_lower_than_batch_size?(batch_size)
    
    puts "Batch from index #{lower_batch_index}-#{i} will be: Size #{bytes_to_megabytes(batch_size)} / #{is_batch_ready}..."
    if is_batch_ready then
      return {
        batch_index: batch_index_factory(lower_batch_index, i, batch_size),
        new_lower_batch_index: i
      }
    end
    
    !is_batch_ready
  end
end

def batch_index_builder(xml_feed, item_count)
  batch_indexes_queue = []
  lower_batch_index = 0
  
  batch_count = 0 
  while lower_batch_index < item_count do
    batch_indexes_metadata = batch_index_search(xml_feed, lower_batch_index, item_count)
    
    batch_indexes_queue << batch_indexes_metadata[:batch_index]
    lower_batch_index = batch_indexes_metadata[:new_lower_batch_index] + 1
        
    batch_count += 1
    puts "Batch count #{batch_count} >>>>" 
  end
  # p batch_indexes_queue

  batch_indexes_queue
end

def batch_builder(xml_feed, batch_index)
  # p batch_index
  batch_search_pattern = "//rss//channel//item[position() >= #{batch_index[:lower_batch_index]} and position() <= #{batch_index[:upper_batch_index]}]"
  current_batch_itens = xml_feed.xpath(batch_search_pattern).flat_map do |item|
    {
      description: xml_node_text_extractor(item, "description"),
      title: xml_node_text_extractor(item, "title"),
      id: xml_node_text_extractor(item, "g:id").to_s
    }
  end 
end

def batch_sender(external_service, xml_feed, batch_queue)
  batch_queue.each do |current_batch_itens_indexes|
    external_service.call( Oj.dump(batch_builder(xml_feed, current_batch_itens_indexes)) )
  end
end

#main vars

xml_feed = Nokogiri::XML.parse(File.read("feed.xml"))

puts "Item count ->"
item_count = xml_feed.xpath("count(//rss//channel//item)").to_i
puts item_count

batch_indexes_queue = batch_index_builder(xml_feed, item_count)

external_service = ExternalService.new
batch_sender(external_service, xml_feed, batch_indexes_queue)



# drafts


# messages = Concurrent::Channel.new( capacity: 10 )

# Concurrent::Channel.go do

#   p @itens.count 
#   @itens.each_with_index do |item, i|
#     current_item = {
#       description: item.xpath("description").children.first.text,
#       title: item.xpath("title").children.first.text,
#       id: item.xpath("g:id").children.first.to_s
#     }  
#     parsed_item = {
#       item: current_item, 
#       size: current_item.to_s.bytesize,
#       index: i 
#     }
#     puts "Concurrent"
#     p parsed_item

#     messages << parsed_item
#   end
# end

# 

# Concurrent::Channel.select do |s|
  #s.take(c1) { |msg| print "received #{msg}\n" }
  #s.take(c2) { |msg| print "received #{msg}\n" }

  # msg = ~messages
  # puts msg
  # s.take(messages) { |msg| print "received #{msg}\n" }
# end

