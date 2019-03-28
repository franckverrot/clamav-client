module ClamAV
  class Base
    class Error < StandardError; end
    class ConnectionError < Error; end
    class ConnectTimeoutError < ConnectionError; end
    class ReadTimeoutError < ConnectionError; end
    class WriteTimeoutError < ConnectionError; end

    attr_writer :unix_socket
    attr_writer :tcp_host
    attr_writer :tcp_port
    attr_writer :connect_timeout
    attr_writer :write_timeout
    attr_writer :read_timeout
    attr_writer :connection
    attr_accessor :options

    def initialize(*args)
      args.each do |arg|
        case arg
        when Connection
          @connection = arg
        when Hash
          @options = arg.reverse_merge(env_options)
        end
      end
    end

    [
      :connect_timeout,
      :write_timeout,
      :read_timeout,
    ].each do |m|
      define_method(m) do
        options[m]
      end

      define_method("#{m}=") do |value|
        options[m] = value
      end
    end

    def env_options
      @env_options ||= {
        connect_timeout: ENV.fetch("CLAMD_TCP_CONNECT_TIMEOUT", nil),
        write_timeout: ENV.fetch("CLAMD_TCP_WRITE_TIMEOUT", nil)
        read_timeout: ENV.fetch("CLAMD_TCP_READ_TIMEOUT", nil)
      }
    end

    def execute(command)
      begin
        command.call(connection)
      rescue Errno::ETIMEDOUT => e
        disconnect!

        raise ConnectTimeoutError.new(e.to_s)
      rescue SocketError, Errno::ECONNRESET, Errno::ECONNREFUSED, Errno::ENETDOWN  => e
        disconnect!

        raise ConnectionError.new(e.to_s)
      rescue => e
        disconnect!

        raise e
      end
    end

    def connection
      @connection ||= default_connection.tap do |conn|
        connect!(conn)
      end
    end

    def default_connection
      ClamAV::Connection.new(
        client: self,
        socket: build_socket,
        wrapper: ::ClamAV::Wrappers::NewLineWrapper.new
      )
    end

    def connect!(conn=nil)
      (conn || @connection).establish_connection
    rescue Errno::ETIMEDOUT => e
      @connection = nil

      raise ConnectTimeoutError.new(e.to_s)
    rescue SocketError, Errno::ECONNRESET, Errno::ECONNREFUSED => e
      @connection = nil

      raise ConnectionError.new(e.to_s)
    end

    def disconnect!
      return true if @connection.nil?

      @connection.disconnect!

      @connection = nil
    end

    def build_socket
      raise NotImplementedError
    end

    def ping
      execute Commands::PingCommand.new
    end

    def instream(io)
      execute Commands::InstreamCommand.new(io)
    end

    def scan(file_path)
      execute Commands::ScanCommand.new(file_path)
    end

    def quit
      execute Commands::QuitCommand.new
    end
  end
end
