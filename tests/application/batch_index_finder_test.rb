require 'minitest/autorun'
require 'nokogiri'
require './application/batch_index_finder'
require './application/byte_utils'
require './domain/batch_index'
require './domain/feed'

class BatchIndexFinderTest < Minitest::Test
  def setup
    @sample_xml = <<-XML
      <rss version="2.0">
        <channel>
          <item>
            <title>Item 1 Title (Short)</title>
          </item>
          <item>
            <title>Item 2 Title (Longer)</title>
          </item>
          <item>
            <title>Item 3 Title (Very Long)</title>
          </item>
          <item>
            <title>Item 4 Title (Short)</title>
          </item>
        </channel>
      </rss>
    XML
    @feed = Domain::Feed.new(Nokogiri::XML.parse(@sample_xml), 4)
  end

  def test_builder_with_small_items
    finder = Application::BatchIndexFinder.new(@feed)
    batch_indexes = finder.builder do |i|
    end

    assert_equal 2, batch_indexes.size

    assert_equal 0, batch_indexes[0].lower_batch_index
    assert_equal 2, batch_indexes[0].upper_batch_index
  end

  def test_builder_with_large_items
    @sample_xml.gsub!('(Short)', '(Very Large Content)')
    @feed = Domain::Feed.new(Nokogiri::XML(@sample_xml), 4)
    finder = Application::BatchIndexFinder.new(@feed)
    batch_indexes = finder.builder do |i|
    end

    assert_equal 2, batch_indexes.size
  end

  def test_builder_with_empty_feed
    empty_feed = Domain::Feed.new(Nokogiri::XML.parse('<rss version="2.0"></rss>'), 0)
    finder = Application::BatchIndexFinder.new(empty_feed)
    batch_indexes = finder.builder do |i|
      assert_empty i
    end

    assert_empty batch_indexes
  end
end