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

require 'timeout'

module ClamAV
  class Connection
    class ReadTimeoutError < ::ClamAV::Client::ReadTimeoutError; end
    class WriteTimeoutError < ::ClamAV::Client::WriteTimeoutError; end

    attr_accessor :client
    attr_accessor :socket
    attr_accessor :wrapper

    def initialize(attrs={})
      attrs.each do |attr, value|
        send("#{attr}=", value)
      end

      begin
        validate!
      rescue => e
        @client = nil
        @socket = nil
        @wrapper = nil

        raise e
      end
    end

    def validate!
      missing_required_argument(:client) if !client
      missing_required_argument(:socket) if !socket
      missing_required_argument(:wrapper) if !wrapper
    end

    [
      :tcp?,
      :file,
      :connect_timeout,
      :read_timeout,
      :write_timeout,
    ].each do |m|
      define_method(m) do
        client.send(m)
      end
    end

    def establish_connection
      write_request("IDSESSION")
    end

    def write_request(str)
      return write_request_with_timeout(str) if write_timeout

      write_request_without_timeout(str)
    end

    def write_request_without_timeout(str)
      wrapped_request = @wrapper.wrap_request(str)

      @socket.write wrapped_request
    end

    def write_request_with_timeout(str)
      timeout(connect_timeout) do
        write_request_without_timeout(str)
      end
    rescue Timeout::Error => e

      raise WriteTimeoutError.new(e.to_s)
    end

    def read_response
      return read_response_with_timeout if read_timeout

      read_response_without_timeout
    end

    def read_response_without_timeout
      @wrapper.read_response(@socket)
    end

    def read_response_with_timeout
      timeout(read_timeout) do
        read_response_without_timeout
      end
    rescue Timeout::Error => e
      raise ReadTimeoutError.new(e.to_s)
    end

    def disconnect!
      return true if @socket.nil?

      @socket.closed?

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
