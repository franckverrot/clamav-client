module ClamAV
  class UnixSocketClient
    DEFAULT_SOCKET = '/var/run/clamav/clamd.ctl'.freeze

    [
      :unix_socket,
    ].each do |m|
      define_method(m) do
        options[m]
      end

      define_method("#{m}=") do |value|
        options[m] = value
      end
    end

    def env_options
      super.tap do |eo|
        eo[:unix_socket] = ENV.fetch('CLAMD_UNIX_SOCKET', DEFAULT_SOCKET.dup)
      end
    end

    def build_socket
      ::UNIXSocket.new(unix_socket)
    rescue Errno::ETIMEDOUT => e
      raise ConnectTimeoutError.new(e.to_s)
    rescue SocketError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
      raise ConnectionError.new(e.to_s)
    end
  end
end
