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
require "clamav/configuration"
require "clamav/commands/ping_command"
require "clamav/commands/quit_command"
require "clamav/commands/scan_command"
require "clamav/commands/instream_command"
require "clamav/util"
require "clamav/wrappers/new_line_wrapper"
require "clamav/wrappers/null_termination_wrapper"

module ClamAV
  class Client
    def self.config_clamav_client(instream_max_chunk_size:)
      @configuration = ClamAV::Configuration.new

      if instream_max_chunk_size
        @configuration.instream_max_chunk_size = instream_max_chunk_size.to_i
      end
      @configuration
    end

    def self.configuration
      @configuration || ClamAV::Configuration.new
    end

    def initialize(connection = default_connection)
      @connection = connection
      @configuration = ClamAV::Client.configuration
      connection.establish_connection
    end

    def execute(command)
      command.call(@connection)
    end

    def default_connection
      ClamAV::Connection.new(
        socket: resolve_default_socket,
        wrapper: ::ClamAV::Wrappers::NewLineWrapper.new
      )
    end

    def resolve_default_socket
      unix_socket, tcp_host, tcp_port = ENV.values_at('CLAMD_UNIX_SOCKET', 'CLAMD_TCP_HOST', 'CLAMD_TCP_PORT')
      if tcp_host && tcp_port
        ::TCPSocket.new(tcp_host, tcp_port)
      else
        ::UNIXSocket.new(unix_socket || '/var/run/clamav/clamd.ctl')
      end
    end

    def ping
      execute Commands::PingCommand.new
    end

    def safe?(target)
      return instream(target).virus_name.nil? if target.is_a?(StringIO)
      scan(target).all? { |file| file.virus_name.nil? }
    end

    private

    def instream(io)
      execute Commands::InstreamCommand.new(io, @configuration.instream_max_chunk_size)
    end

    def scan(file_path)
      execute Commands::ScanCommand.new(file_path)
    end
  end
end
