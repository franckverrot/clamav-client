# clamav-client - ClamAV client
# Copyright (C) 2014 Franck Verrot <franck@verrot.fr>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "clamav/connection"
require "clamav/commands/ping_command"
require "clamav/commands/quit_command"
require "clamav/commands/scan_command"
require "clamav/commands/instream_command"
require "clamav/util"
require "clamav/wrappers/new_line_wrapper"
require "clamav/wrappers/null_termination_wrapper"

module ClamAV
  DEBUG = ENV.fetch('DEBUG', '0').strip == '1'

  class Client
    class Error < StandardError; end
    class ConnectionError < Error; end
    class ConnectTimeoutError < ConnectionError; end

    attr_writer :unix_socket
    attr_writer :tcp_host
    attr_writer :tcp_port
    attr_writer :connect_timeout
    attr_writer :connection

    def initialize(*args)
      args.each do |arg|
        case arg
        when Connection
          @connection = arg
        when Hash
          arg.each do |attr, value|
            send("#{attr}=", value)
          end
        end
      end
    end

    def execute(command)
      begin
        command.call(connection)
      rescue Errno::ETIMEDOUT => e
        raise ConnectTimeoutError.new(e.to_s)
      rescue SocketError => e
        raise ConnectionError.new(e.to_s)
      end
    end

    def connection
      @connection ||= default_connection.tap do |conn|
        conn.establish_connection
      end
    end

    def default_connection
      ClamAV::Connection.new(
        socket: resolve_default_socket,
        wrapper: ::ClamAV::Wrappers::NewLineWrapper.new
      )
    end

    def tcp_host
      @tcp_host ||= ENV.fetch('CLAMD_TCP_HOST', nil)
    end

    def tcp_port
      @tcp_port ||= ENV.fetch('CLAMD_TCP_PORT', nil)
    end

    def unix_socket
      @unix_socket ||= ENV.fetch('CLAMD_UNIX_SOCKET', '/var/run/clamav/clamd.ctl')
    end

    def connect_timeout
      @connect_timeout ||= ENV.fetch('CLAMD_TCP_CONNECT_TIMEOUT', nil)

      return @connect_timeout if @connect_timeout.nil?

      @connect_timeout = nil if @connect_timeout.empty?

      @connect_timeout
    end

    def tcp?
      !!tcp_host && !!tcp_port
    end

    def file?
      !tcp
    end

    def socket
      return Socket.tcp(tcp_host, tcp_port, tcp_opts) if tcp?

      ::UNIXSocket.new(unix_socket)
    end

    def tcp_opts
      {}.tap do |o|
        o[:connect_timeout] = connect_timeout if connect_timeout
      end
    end

    def resolve_default_socket
      if tcp_host && tcp_port
        Socket.tcp(tcp_host, tcp_port, tcp_opts)
      else
        ::UNIXSocket.new(unix_socket || '/var/run/clamav/clamd.ctl')
      end
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
