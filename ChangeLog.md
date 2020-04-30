# Unreleased

# 3.2.0

  * Add `ClamAV::Client#ping` as a short-hand for executing a ping
  * Add `ClamAV::Client#safe?` as a way to check both streams and files
  * Add support for Ruby 2.7

# 3.1.0

  * Drop support for old Rubies (prior to 2.2)
  * Drop fixtures from the gem

# 3.0.0

  * README.md: Added instructions to install ClamAV on Ubuntu, RedHat and CentOS
  * INSTREAM: fixed a problem parsing the "FOUND" response
  * VirusReponse: The virus file name is now held by the VirusReponse object
  * test/ci-setup.sh : Configure ClamAV on the CI

# 2.0.1

  * README.md : ClamAV's setup notes
  * clamav-client.gemspec : Upgrade gem after yanking it on RG

# 2.0.0

  * lib/clamav/commands/instream_command: Support of INSTREAM
  * lib/clamav/responses.rb : Change insufficient comparison
  * README.md: Now backward-compatible back to Ruby 1.9.2
  * lib/clamav/client.rb : Configure with constants
    * CLAMD_UNIX_SOCKET
    * CLAMD_TCP_HOST
    * CLAMD_TCP_PORT
  * clamav-client.gemspec : Add the minitest gem for older Rubies
  * .travis.yml : New test script. Add support for more Rubies
  * lib/clamav/connection : remove keyword arguments
  * travis.yml : Add basic configuration
  * lib/clamav/wrapper.rb : Host common code
  * lib/clamav/commands/command : Remove dead code
  * Code format consistency.
  * Explicit #call() to better document usage.
  * Code typos; Ruby highlighting; wording.

# 1.0.0

  * Initial release
