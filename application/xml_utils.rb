module Application
  class XmlUtils
    def self.node_text_extractor(node, prop)
      item = node.xpath(prop).children.first
      item.nil? ? "" : item.text
    end
  end
end
