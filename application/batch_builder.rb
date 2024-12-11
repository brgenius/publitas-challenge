require './application/xml_utils'
require './domain/batch_item'

module Application
  class BatchBuilder
    attr_reader :feed, :batch_index
    def initialize(feed, batch_index)
      @feed = feed 
      @batch_index = batch_index
    end

    def queue_builder()
      batch_search_pattern = "//rss//channel//item[position() >= #{@batch_index.lower_batch_index} and position() <= #{@batch_index.upper_batch_index}]"
      current_batch_itens = @feed.xml.xpath(batch_search_pattern).flat_map do |item|
        Domain::BatchItem.new(
          Application::XmlUtils.node_text_extractor(item, "description"),
          Application::XmlUtils.node_text_extractor(item, "title"),
          Application::XmlUtils.node_text_extractor(item, "g:id").to_s
        )
      end 
    end
  end
end
