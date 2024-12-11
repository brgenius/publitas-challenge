require 'concurrent'
require 'concurrent-edge'

require 'nokogiri'
require 'oj'

require './domain/feed'
require './infra/feed'
require './application/batch_index_finder'
require './application/batch_builder'

require './external_service'

## factories

# def batch_index_factory(lower_batch_index, upper_batch_index, batch_size)
#   {lower_batch_index: lower_batch_index, upper_batch_index: upper_batch_index, batch_size: batch_size}
# end

# def xml_node_text_extractor(node, prop)
#   item = node.xpath(prop).children.first
#   item.nil? ? "" : item.text
# end

# ## services

# # What it does:
# #  Searches an index between the current start index ( lower_batch_index ) and the total item count
# #  that has a lower 5MB total string size in bytes, including all item attributes.
# #  The goal here is to find as quick as possible, item indexes from feed that later will be sent to ExternalService
# # 
# # Why it was done this way:
# #  As binary search based on indexes, some batches will not be EXACTLY arround 5mb,
# #  but it's faster than do a sequential search testing each index, formming perfect 5mb batches.
# #  It also relies on Nokogiri gem ability to search inside the xml file by xpath queries 
# def batch_index_search(xml_feed, lower_batch_index, item_count)
#   (lower_batch_index..item_count).to_a.bsearch_index do |i|
    
#     batch_search_pattern = "//rss//channel//item[position() >= #{lower_batch_index} and position() <= #{i}]"
#     batch_size = xml_feed.xpath(batch_search_pattern).to_s.bytesize
#     is_batch_ready = is_lower_than_batch_size?(batch_size)
    
#     if is_batch_ready then
#       puts "Batch from index #{lower_batch_index}-#{i} will contain approximately #{bytes_to_megabytes(batch_size)} mb ..."
#       return {
#         batch_index: batch_index_factory(lower_batch_index, i, batch_size),
#         new_lower_batch_index: i
#       }
#     end
    
#     !is_batch_ready
#   end
# end

# # Generates a queue of batch indexes to be extracted later and sent to ExternalService
# def batch_index_builder(xml_feed, item_count)
#   batch_indexes_queue = []
#   lower_batch_index = 0
  
#   batch_count = 0 
#   while lower_batch_index < item_count do
#     batch_indexes_metadata = batch_index_search(xml_feed, lower_batch_index, item_count)
    
#     batch_indexes_queue << batch_indexes_metadata[:batch_index]
#     lower_batch_index = batch_indexes_metadata[:new_lower_batch_index] + 1
        
#     batch_count += 1
#     puts "Batch count #{batch_count} >>>>" 
#   end

#   batch_indexes_queue
# end

# def batch_builder(xml_feed, batch_index)
#   batch_search_pattern = "//rss//channel//item[position() >= #{batch_index.lower_batch_index} and position() <= #{batch_index.upper_batch_index}]"
#   current_batch_itens = xml_feed.xpath(batch_search_pattern).flat_map do |item|
#     {
#       description: xml_node_text_extractor(item, "description"),
#       title: xml_node_text_extractor(item, "title"),
#       id: xml_node_text_extractor(item, "g:id").to_s
#     }
#   end 
# end

def batch_sender(external_service, feed, batch_queue)
  batch_queue.each do |current_batch_itens_indexes|
    batch_build = Application::BatchBuilder.new(feed, current_batch_itens_indexes)
    
    external_service.call( Oj.dump(batch_build.queue_builder()) )
  end
end

#main vars
feed = Infra::Feed.get_from_file("feed.xml")

batchIndexFinder = Application::BatchIndexFinder.new(feed)
batch_indexes_queue = batchIndexFinder.builder()



external_service = ExternalService.new
batch_sender(external_service, feed, batch_indexes_queue)



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

