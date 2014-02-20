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

require 'test_helper'

describe "ScanCommand" do
  before do
    @conn = Minitest::Mock.new
    @path = 'some path'
  end

  after do
    @conn.verify
  end

  it "can recognize a sane file" do
    @conn.expect(:send_request, "1: #{@path}: OK", ["SCAN #{@path}"])

    ClamAV::Util.stub :path_to_files, [@path] do
      assert ClamAV::Commands::ScanCommand.new(@path).call(@conn)
    end
  end
end
