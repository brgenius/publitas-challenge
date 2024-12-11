require 'async'
require 'oj'

module Application
  class BatchSender
    attr_reader :external_service, :feed, :batch_queue

    def initialize(external_service, feed, batch_queue)
      @external_service = external_service
      @feed = feed
      @batch_queue = batch_queue
    end

    def send()
      @batch_queue.each do |current_batch_itens_indexes|
        Async do |task|
          puts "Batch will start"
          
          batch_build = Application::BatchBuilder.new(@feed, current_batch_itens_indexes)
          @external_service.call( Oj.dump(batch_build.queue_builder()) )

          puts "Batch completed\n"
        end
      end
    end  
  end
end
