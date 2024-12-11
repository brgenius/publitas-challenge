module Domain
  class BatchIndex
    attr_accessor :lower_batch_index, :upper_batch_index, :batch_size

    def initialize(lower_batch_index, upper_batch_index, batch_size)
      @lower_batch_index = lower_batch_index
      @upper_batch_index = upper_batch_index
      @batch_size = batch_size
    end
  end
end
