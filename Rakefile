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

require 'rubygems'
require 'rubygems/specification'

require 'bundler'
Bundler::GemHelper.install_tasks

$:<< 'lib'
require 'clamav/client'

$stdout.puts """
ClamAV::Client Copyright (C) 2014 Franck Verrot <franck@verrot.fr>
This program comes with ABSOLUTELY NO WARRANTY; for details type `rake license'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `rake license' for details.

"""

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  #t.verbose = true
  #t.warning = true
end

Rake::TestTask.new(:unit_tests) do |t|
  t.libs << "test"
  t.pattern = "test/unit/**/*_test.rb"
  #t.verbose = true
  #t.warning = true
end

Rake::TestTask.new(:integration_tests) do |t|
  t.libs << "test"
  t.pattern = "test/integration/**/*_test.rb"
  #t.verbose = true
  #t.warning = true
end


def gemspec
  @gemspec ||= begin
                 file = File.expand_path('../clamav-client.gemspec', __FILE__)
                 eval(File.read(file), binding, file)
               end
end

desc "Clean the current directory"
task :clean do
  rm_rf 'tmp'
  rm_rf 'pkg'
end

desc "Run the full spec suite"
task :full => ["clean", "test"]

desc "install the gem locally"
task :install => :package do
  sh %{gem install pkg/#{gemspec.name}-#{gemspec.version}}
end

desc "validate the gemspec"
task :gemspec do
  gemspec.validate
end

desc "Build the gem"
task :gem => [:gemspec, :build] do
  mkdir_p "pkg"
  sh "gem build clamav-client.gemspec"
  mv "#{gemspec.full_name}.gem", "pkg"
end

desc "Install ClamAV::Client"
task :install => :gem do
  sh "gem install pkg/#{gemspec.full_name}.gem"
end

task :default => :full

task :license do
  `open http://www.gnu.org/licenses/gpl.txt`
end

task :console do
  require 'pry'
  Pry.start
end
