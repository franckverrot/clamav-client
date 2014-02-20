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

describe "NewLineWrapper" do
  let(:wrapper) { ClamAV::Wrappers::NewLineWrapper.new }

  it "wraps requests" do
    wrapper.wrap_request("foo").must_equal "nfoo\n"
  end

  it "read responses" do
    # Mock an IO object
    socket_mock = Class.new do
      def getc
        @val ||= "hello\n"
        @val.slice!(0)
      end
    end.new

    wrapper.read_response(socket_mock).must_equal "hello"
  end

end
