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
    class Command

      def call; raise NotImplementedError.new; end

      protected

        # OK response looks like "1: stream: OK" or "1: /tmp/NOT_A_VIRUS.TXT: OK"
        # FOUND response looks like "1: stream: Eicar-Test-Signature FOUND" or "1: /tmp/EICAR.COM: Eicar-Test-Signature FOUND"
        def get_status_from_response(str)
          /^(?<id>\d+): (?<filepath>.*): (?<virus_name>.*)\s?(?<status>(OK|FOUND))$/ =~ str
          case status
          when 'OK' then ClamAV::SuccessResponse.new(filepath)
          when 'FOUND' then ClamAV::VirusResponse.new(filepath, virus_name.strip)
          else ClamAV::ErrorResponse.new(str)
          end
        end

    end
  end
end
