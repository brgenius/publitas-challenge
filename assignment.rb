require './requirements'

feed = Infra::Feed.get_from_file("feed.xml")

batchIndexFinder = Application::BatchIndexFinder.new(feed)
batch_indexes_queue = batchIndexFinder.builder()

external_service = ExternalService.new
batch_sender = Application::BatchSender.new(external_service, feed, batch_indexes_queue)
batch_sender.send()
