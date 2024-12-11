module Application
  class ByteUtils
    def self.to_megabytes (bytes)
      bytes / (1024.0 * 1024.0) 
    end
  
    def self.is_lower_than_batch_size?(bytes, batch_size_in_mb)
      self.to_megabytes(bytes) <= batch_size_in_mb
    end
  end
end