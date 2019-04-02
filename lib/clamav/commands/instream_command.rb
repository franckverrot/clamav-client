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

module ClamAV
  module Commands
    class InstreamCommand < Command

      def initialize(io, max_chunk_size = 1024)
        @io = begin io rescue raise ArgumentError, 'io is required', caller; end
        @max_chunk_size = max_chunk_size
      end

      def call(conn)
        conn.write_request("INSTREAM")

        while(packet = @io.read(@max_chunk_size))
          packet_size = [packet.size].pack("N")
          conn.raw_write("#{packet_size}#{packet}")
        end
        conn.raw_write("\x00\x00\x00\x00")
        get_status_from_response(conn.read_response)
      end

    end
  end
end
