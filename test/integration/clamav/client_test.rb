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

      it "can be used as #ping" do
        assert_equal client.execute(ping_command), client.ping
      end
    end

    describe "scan" do
      let(:base_path) { File.expand_path('../../../../', __FILE__) }
      let(:dir) { File.join(base_path, 'test/fixtures') }

      it "can be started" do
        results = client.execute(ClamAV::Commands::ScanCommand.new(dir))

        expected_results = {
          "#{base_path}/test/fixtures/clamavtest.gz"  => ClamAV::VirusResponse,
          "#{base_path}/test/fixtures/clamavtest.txt" => ClamAV::VirusResponse,
          "#{base_path}/test/fixtures/clamavtest.zip" => ClamAV::VirusResponse,
          "#{base_path}/test/fixtures/innocent.txt"   => ClamAV::SuccessResponse
        }

        results.each do |result|
          expected_result = expected_results[result.file]
          assert_equal expected_result, result.class
        end
      end

      it "can be used as #scan" do
        assert_equal client.execute(ClamAV::Commands::ScanCommand.new(dir)), client.send(:scan, dir)
      end
    end

    describe "instream" do
      let(:dir) { File.expand_path('../../../../test/fixtures', __FILE__) }

      it "can recognize a sane file" do
        command = build_command_for_file('innocent.txt')
        client.execute(command).must_equal ClamAV::SuccessResponse.new("stream")
      end

      it "can recognize an infected file" do
        command = build_command_for_file('clamavtest.txt')
        client.execute(command).must_equal ClamAV::VirusResponse.new("stream", "ClamAV-Test-Signature")
      end

      it "can be used as #instream" do
        io = File.open(File.join(dir, 'innocent.txt'))
        assert_equal client.execute(ClamAV::Commands::InstreamCommand.new(io)), client.send(:instream, io)
      end

      describe "instream_comment with custom instream_max_chunk_size" do
        let(:instream_max_chunk_size) { 2048 }

        before do
          ClamAV::Client.config_client(instream_max_chunk_size: instream_max_chunk_size)
        end

        after do
          ClamAV::Client.config_client(instream_max_chunk_size: 1024)
        end

        it "can recognize a sane file" do
          command = build_command_for_file('innocent.txt', instream_max_chunk_size)
          client.execute(command).must_equal ClamAV::SuccessResponse.new("stream")
        end

        it "can recognize an infected file" do
          command = build_command_for_file('clamavtest.txt', instream_max_chunk_size)
          client.execute(command).must_equal ClamAV::VirusResponse.new("stream", "ClamAV-Test-Signature")
        end

        it "can be used as #instream" do
          io = File.open(File.join(dir, 'innocent.txt'))
          instream_command = ClamAV::Commands::InstreamCommand.new(io, instream_max_chunk_size)
          assert_equal client.execute(instream_command), client.send(:instream, io)
        end
      end

      def build_command_for_file(file, instream_max_chunk_size = nil)
        io = File.open(File.join(dir, file))

        if instream_max_chunk_size
          ClamAV::Commands::InstreamCommand.new(io, instream_max_chunk_size)
        else
          ClamAV::Commands::InstreamCommand.new(io)
        end
      end
    end

    describe 'safe?' do
      let(:dir) { File.expand_path('../../../../test/fixtures', __FILE__) }

      it 'returns true if the given io is safe' do
        io = build_io_obj('innocent.txt')
        assert client.safe?(io)
      end

      it 'returns false if the given io is infected' do
        io = build_io_obj('clamavtest.txt')
        refute client.safe?(io)
      end

      it 'returns false if there is any infected file in the given files' do
        refute client.safe?(dir)
      end

      it 'returns true if all the give file is safe' do
        assert client.safe?("#{dir}/innocent.txt")
      end

      def build_io_obj(file)
        content = File.read(File.join(dir, file))
        io = StringIO.new(content)
      end
    end
  end
end
