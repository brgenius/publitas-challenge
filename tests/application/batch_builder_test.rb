require 'minitest/autorun'
require 'nokogiri'
require './application/xml_utils'
require './application/batch_builder'
require './domain/batch_index'
require './domain/feed'

class BatchBuilderTest < Minitest::Test
  def setup
    @sample_xml = <<-XML
      <?xml version='1.0' encoding='utf-8'?>
      <rss version='2.0' xmlns:g="http://base.google.com/ns/1.0">
        <channel>
          <item>
            <title>Item 1 Title</title>
            <description>Item 1 Description</description>
            <g:id>12345</g:id>
          </item>
          <item>
            <title>Item 2 Title</title>
            <description>Item 2 Description</description>
            <g:id>67890</g:id>
          </item>
          <item>
            <title>Item 3 Title</title>
            <description>Item 3 Description</description>
            <g:id>01234</g:id>
          </item>
        </channel>
      </rss>
    XML

    @feed = Domain::Feed.new(Nokogiri::XML.parse(@sample_xml), 3)
  end

  def test_queue_builder_with_valid_batch_index
    batch_index = Domain::BatchIndex.new(1, 2, 1000)
    builder = Application::BatchBuilder.new(@feed, batch_index)
    batch_items = builder.queue_builder

    assert_equal 2, batch_items.size
    assert_equal "Item 1 Description", batch_items[0].description
    assert_equal "Item 2 Title", batch_items[1].title
    assert_equal "12345", batch_items[0].id
    assert_equal "67890", batch_items[1].id
  end

  def test_queue_builder_with_empty_batch
    batch_index = Domain::BatchIndex.new(4, 4, 1000)
    builder = Application::BatchBuilder.new(@feed, batch_index)
    batch_items = builder.queue_builder

    assert_empty batch_items
  end

  def test_queue_builder_with_invalid_xml
    invalid_feed = "This is not valid XML"

    invalid = Domain::Feed.new(Nokogiri::XML.parse(@invalid_feed), 3)
    builder = Application::BatchBuilder.new(invalid, Domain::BatchIndex.new(0, 0, 0))
    assert_empty builder.queue_builder
  end
end