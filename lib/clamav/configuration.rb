module ClamAV
  class Configuration
    attr_reader :instream_max_chunk_size

    DEFAULT_INSTREAM_MAX_CHUNK_SIZE = 1024

    def initialize(instream_max_chunk_size: DEFAULT_INSTREAM_MAX_CHUNK_SIZE)
      @instream_max_chunk_size = instream_max_chunk_size
    end
  end
end
