require 'minitest/autorun'
require 'nokogiri'
require './application/xml_utils'

class XmlUtilsTest < Minitest::Test
  def setup
    @xml_doc = Nokogiri::XML('<root><item>Text Content</item></root>')
  end

  def test_node_text_extractor_with_existing_node
    result = Application::XmlUtils.node_text_extractor(@xml_doc.root, './item')
    assert_equal 'Text Content', result
  end

  def test_node_text_extractor_with_non_existent_node
    result = Application::XmlUtils.node_text_extractor(@xml_doc.root, './non_existent_node')
    assert_equal '', result
  end
end