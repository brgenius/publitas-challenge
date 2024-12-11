require 'nokogiri'
require './domain/feed'

module Infra
  class Feed
    def self.get_from_file(file_path)
      # xml_feed = Nokogiri::XML.parse(File.read("feed.xml"))
      xml_feed = Nokogiri::XML.parse(File.read(file_path))
      
      puts "Item count ->"
      item_count = xml_feed.xpath("count(//rss//channel//item)").to_i
      puts item_count
  
      Domain::Feed.new(xml_feed, item_count)
    end
  end
end