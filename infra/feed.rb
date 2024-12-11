require 'nokogiri'
require 'open-uri'

require './domain/feed'

module Infra
  class Feed
    def self.get_from_url(url)
      puts "Downloading XML file"
      xml_feed = Nokogiri::XML.parse(URI.open(url))
      
      self.builder(xml_feed)
    end

    def self.get_from_file(file_path)
      puts "Reading from feed.xml file"
      xml_feed = Nokogiri::XML.parse(File.read(file_path))
      
      self.builder(xml_feed)
    end

    private 

    def self.builder(xml_feed)
      puts "Item count ->"
      item_count = xml_feed.xpath("count(//rss//channel//item)").to_i
      puts item_count
  
      Domain::Feed.new(xml_feed, item_count)
    end
  end
end