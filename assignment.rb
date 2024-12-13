# You may run passing a xml url as a argument, like below or using a previously download file, called feed.xml
#
# $ ruby assignment.rb http://challenge.publitas.com/feed.xml
# or 
# $ ruby assignment.rb 

require 'uri'
require './requirements'

feed = nil
for arg in ARGV
  feed = Infra::Feed.get_from_url(arg) if arg =~ URI::regexp and arg.end_with? "xml"
end

def main(feed)
  if !feed.has_valid_itens? then
    puts "No valid itens were found in the given file. Exiting..."

    return
  end

  external_service = ExternalService.new
  Application::BatchIndexFinder.new(feed).builder() do |batch_indexes_queue|
    Application::BatchSender.new(external_service, feed, batch_indexes_queue).send()
  end
end

feed = Infra::Feed.get_from_file("feed.xml") if feed.nil?

main(feed)