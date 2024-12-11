require 'uri'
require './requirements'

feed = nil
for arg in ARGV
  feed = Infra::Feed.get_from_url(arg) if arg =~ URI::regexp and arg.end_with? "xml"
end

def main(feed)
  batch_indexes_queue = Application::BatchIndexFinder.new(feed).builder()

  external_service = ExternalService.new
  batch_sender = Application::BatchSender.new(external_service, feed, batch_indexes_queue)
  batch_sender.send()
end

feed = Infra::Feed.get_from_file("feed.xml") if feed.nil?

main(feed)