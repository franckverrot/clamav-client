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

describe "INSTREAM command" do
  before do
    @conn = Minitest::Mock.new
    @io   = ::StringIO.new('hello')
  end

  after do
    @conn.verify
  end

  it "can process an IO object" do
    @conn.expect(:write_request, nil, ["INSTREAM"])
    @conn.expect(:raw_write, nil, ["\x00\x00\x00\x05hello"])
    @conn.expect(:raw_write, nil, ["\x00\x00\x00\x00"])
    @conn.expect(:read_response, '1: stream: OK', [])

    assert ClamAV::Commands::InstreamCommand.new(@io).call(@conn)
  end

  it "can specify the size of read chunks" do
    mock_env("CLAMAV_INSTREAM_MAX_CHUNK_SIZE" => '1') do
      @conn.expect(:write_request, nil, ["INSTREAM"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x01h"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x01e"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x01l"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x01l"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x01o"])
      @conn.expect(:raw_write, nil, ["\x00\x00\x00\x00"])
      @conn.expect(:read_response, '1: stream: OK', [])

      assert ClamAV::Commands::InstreamCommand.new(@io).call(@conn)
    end
  end

  def mock_env(partial_env_hash)
    old = ENV.to_hash
    ENV.update partial_env_hash
    begin
      yield
    ensure
      ENV.replace old
    end
  end
end
