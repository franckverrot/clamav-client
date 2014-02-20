# ClamAV::Client

ClamAV::Client is a client library that can talk to the clam daemon.

## Installation

Add this line to your application's Gemfile:

    gem 'clamav-client', require: 'clamav/client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clamav-client

Alternatively, you can spawn a `pry` console right away by just running:

    $ rake console

## Requirements

* Ruby >= 2 (and Ruby >= 2.1 to be able to contribute to the project as it's making use of required keyword arguments)
* clamd

## Usage

The `ClamAV::Client` class is responsible for opening a connection to a remote
ClamAV clam daemon.

You will find below the implemented commands.

### PING => Boolean

Pings the daemon to check whether it is alive.

    client = ClamAV::Client.new
    client.execute(ClamAV::Commands::PingCommand.new)
    => true

### SCAN <file_or_directory> => Array[Response]

Scans a file or a directory for the existence of a virus.

The absolute path must be given to that command.

    client = ClamAV::Client.new

    client.execute(ClamAV::Commands::ScanCommand.new('/tmp/path/foo.c')
    => [#<ClamAV::SuccessResponse:0x007fbf314b9478 @file="/tmp/foo.c">]

    client.execute(ClamAV::Commands::ScanCommand.new('/tmp/path')
    => [#<ClamAV::SuccessResponse:0x007fc30c273298 @file="/tmp/path/foo.c">,
     #<ClamAV::SuccessResponse:0x007fc30c272910 @file="/tmp/path/foo.cpp">]


### Custom commands

Custom commands can be given to the client. The contract between the client
and the command is thru the `call` method call. The `call` method is being
passed a `Connection` object.

Here's a simple example that implements the `VERSION` command:

    # Build the client
    client = ClamAV::Client.new

    # Create the command lambda
    version_command = lambda { |conn| conn.send_request("VERSION") }
    => #<Proc:0x007fc0d0c14b28>

    # Execute the command
    client.execute(version_command)
    => "1: ClamAV 0.98.1/18489/Tue Feb 18 16:00:05 2014"


## Defaults

The default values in use are:

  * clamd socket: UNIX Socket, located at `/tmp/clamd/socket`;
  * New-line terminated commands.

These defaults can be changed by injecting new defaults.

## Injecting dependencies

### Client

The main object is the `Client` object. It is responsible for executing the commands.
This object can receive a custom connection object.

### Connection

The connection object is the bridge between the raw socket object and the
protocol being used between the client and the daemon.

`clamd` supports two kinds of delimiters:

  * NULL terminated commands
  * New-line terminated commands

The management of those delimiters is done with the wrapper argument.

### Wrapper

The wrapper is responsible for taking the incoming request with the
`wrap_request` method, and parsing the response with the `read_response`
method.


## Contributing

1. Fork it ( https://github.com/franckverrot/clamav-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
