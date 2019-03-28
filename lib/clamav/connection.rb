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

require 'socket'

module ClamAV
  class Connection
    attr_accessor :socket

    def initialize(args)
      socket  = args.fetch(:socket)  { missing_required_argument(:socket) }
      wrapper = args.fetch(:wrapper) { missing_required_argument(:wrapper) }

      if socket && wrapper
        @socket = socket
        @wrapper = wrapper
      else
        raise ArgumentError
      end
    end

    def establish_connection
      wrapped_request = @wrapper.wrap_request("IDSESSION")

      puts "Writing request: #{wrapped_request}" if DEBUG

      @socket.write wrapped_request
    end

    def write_request(str)
      wrapped_request = @wrapper.wrap_request(str)

      puts "Writing request: #{wrapped_request}" if DEBUG

      @socket.write wrapped_request
    end

    def read_response
      @wrapper.read_response(@socket).tap do |r|

      puts "Read Response: #{r}" if DEBUG

      end
    end

    def disconnect!
      return true if @socket.nil?

      @socket.closed?

      puts "Disconnecting..." if DEBUG

      @socket.closed?.tap do
        @socket = nil
      end
    end

    def send_request(str)
      write_request(str)
      read_response
    end

    def raw_write(str)
      @socket.write str
    end

    private
    def missing_required_argument(key)
      raise ArgumentError, "#{key} is required"
    end
  end
end
