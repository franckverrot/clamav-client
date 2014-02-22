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

describe "ClamAV::Client Integration Tests" do
  describe "default new line delimiter" do
    let(:client) { ClamAV::Client.new }

    describe "any callable" do
      it "can be used" do
        assert client.execute(lambda { |conn| true })
      end
    end

    describe "ping" do
      let(:ping_command) { ClamAV::Commands::PingCommand.new }

      it "can be sent" do
        assert client.execute(ping_command)
      end

      it "can be sent multiple times" do
        assert client.execute(ping_command)
        assert client.execute(ping_command)
      end
    end

    describe "scan" do
      it "can be started" do
        dir = File.expand_path('../../../../test/fixtures', __FILE__)
        results = client.execute(ClamAV::Commands::ScanCommand.new(dir))

        expected_results = [
          ClamAV::VirusResponse.new("/Users/cesario/Development/clamav-client/test/fixtures/clamavtest.gz"),
          ClamAV::VirusResponse.new("/Users/cesario/Development/clamav-client/test/fixtures/clamavtest.txt"),
          ClamAV::VirusResponse.new("/Users/cesario/Development/clamav-client/test/fixtures/clamavtest.zip"),
          ClamAV::SuccessResponse.new("/Users/cesario/Development/clamav-client/test/fixtures/innocent.txt")
        ]
        assert_equal expected_results, results
      end
    end

    describe "instream" do
      it "can be started" do
        dir = File.expand_path('../../../../test/fixtures', __FILE__)

        [
          ['clamavtest.txt', ClamAV::VirusResponse],
          ['innocent.txt',   ClamAV::SuccessResponse]
        ].each do |file, response_class|
          io      = File.open(File.join(dir, file))
          command = ClamAV::Commands::InstreamCommand.new(io)
          client.execute(command).must_equal response_class.new("stream")
        end
      end
    end
  end
end
