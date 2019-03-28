require 'socket'
require 'timeout'

module ClamAV
  class TCPClient < ::ClamAV::Client
    DEFAULT_HOST = 'localhost'.freeze
    DEFAULT_PORT = 3310

    [
      :tcp_host,
      :tcp_port,
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
        eo[:tcp_host] = ENV.fetch('CLAMD_TCP_HOST', DEFAULT_HOST.dup)
        eo[:tcp_port] = ENV.fetch('CLAMD_TCP_PORT', DEFAULT_PORT)
      end
    end

    def build_socket
      return Socket.tcp(tcp_host, tcp_port, tcp_opts) if tcp?
    rescue Errno::ETIMEDOUT => e
      raise ConnectTimeoutError.new(e.to_s)
    rescue SocketError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
      raise ConnectionError.new(e.to_s)
    end

    def tcp_opts
      {}.tap do |o|
        o[:connect_timeout] = connect_timeout if connect_timeout
      end
    end
  end
end