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
  describe "Util" do
    describe "absolute_path" do
      it "transforms a single file to an array of one element" do
        assert_equal [File.absolute_path(__FILE__)], ClamAV::Util.path_to_files(__FILE__)
      end

      it "transforms a directory to an array of N element" do
        files = %w(
          /Users/cesario/Development/clamav-client/test/integration/clamav/client_test.rb
          /Users/cesario/Development/clamav-client/test/integration/clamav/util_test.rb
        )
        assert_equal files, ClamAV::Util.path_to_files(File.dirname(__FILE__))
      end
    end
  end
end
