# Unreleased (3.0.0)

  * Added instructions to install ClamAV on Ubuntu, RedHat and CentOS
  * Fixed a problem parsing the "FOUND" response
  * Extract the virus name and fix an error if the virus name is anything other than the test virus

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
