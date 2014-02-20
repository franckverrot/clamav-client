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

require 'clamav/commands/command'
require 'clamav/responses/error_response'
require 'clamav/responses/success_response'
require 'clamav/responses/virus_response'
module ClamAV
  module Commands
    class ScanCommand < Command
      Statuses = {
        'ERROR' => ClamAV::ErrorResponse,
        'OK' => ClamAV::SuccessResponse,
        'ClamAV-Test-Signature FOUND' => ClamAV::VirusResponse
      }

      def initialize(path, path_finder = Util)
        @path, @path_finder = path, path_finder
      end

      def call(conn)
        @path_finder.path_to_files(@path).map { |file| scan_file(conn, file) }
      end

      protected
      def scan_file(conn, file)
        get_status_from_response(conn.send_request("SCAN #{file}"))
      end

      def get_status_from_response(str)
        case str
        when 'Error processing command. ERROR'
          ErrorResponse.new(str)
        else
          /(?<id>\d+): (?<filepath>.*): (?<status>.*)/ =~ str
          Statuses[status].new(filepath)
        end
      end
    end
  end
end
