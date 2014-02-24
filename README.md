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
    
### Installing ClamAV's daemon

#### On OSX

If you are using brew, just run

```shell
brew install clamav
```
#### On Linux (Ubuntu)
```shell
sudo apt-get install clamav-daemon clamav-freshclam clamav-unofficial-sigs
sudo freshclam
sudo service clamav-daemon start
```

## Requirements

* Ruby >= 1.9.2
* clamd

## Usage

The `ClamAV::Client` class is responsible for opening a connection to a remote
ClamAV clam daemon.

See the implemented commands below.

### PING => Boolean

Pings the daemon to check whether it is alive.

```ruby
client = ClamAV::Client.new
client.execute(ClamAV::Commands::PingCommand.new)
# => true
```

### SCAN <file_or_directory> => Array[Response]

Scans a file or a directory for the existence of a virus.

The absolute path must be given to that command.

```ruby
client = ClamAV::Client.new

client.execute(ClamAV::Commands::ScanCommand.new('/tmp/path/foo.c'))
# => [#<ClamAV::SuccessResponse:0x007fbf314b9478 @file="/tmp/foo.c">]

client.execute(ClamAV::Commands::ScanCommand.new('/tmp/path'))
# => [#<ClamAV::SuccessResponse:0x007fc30c273298 @file="/tmp/path/foo.c">,
#     #<ClamAV::SuccessResponse:0x007fc30c272910 @file="/tmp/path/foo.cpp">]
```

### INSTREAM => Response

Scans an IO-like object for the existence of a virus.

```ruby
client = ClamAV::Client.new

io = StringIO.new('some data')
client.execute(ClamAV::Commands::InstreamCommand.new(io))
# => [#<ClamAV::SuccessResponse:0x007fe471cabe50 @file="stream">]
```

### Custom commands

Custom commands can be given to the client. The contract between the client
and the command is through the `Command#call` method. The `call` method will
receive a `Connection` object.

Here's a simple example implementing the `VERSION` command:

```ruby
# Build the client
client = ClamAV::Client.new

# Create the command lambda
version_command = lambda { |conn| conn.send_request("VERSION") }
# => #<Proc:0x007fc0d0c14b28>

# Execute the command
client.execute(version_command)
# => "1: ClamAV 0.98.1/18489/Tue Feb 18 16:00:05 2014"
```

## Defaults

The default values in use are:

  * clamd socket: UNIX Socket, located at `/var/run/clamav/clamd.ctl`;
  * New-line terminated commands.

These defaults can be changed:

  * by creating the object graph manually;
  * by setting environment variables.

### The object graph

#### Client

The main object is the `Client` object. It is responsible for executing the commands.
It can receive a custom connection object.

#### Connection

The `Connection` object is the bridge between the raw socket object and the
protocol used between the client and the daemon.

`clamd` supports two kinds of delimiters:

  * NULL terminated commands
  * New-line terminated commands

The management of those delimiters is done with the wrapper argument.

#### Wrapper

The wrapper is responsible for taking the incoming request with the
`wrap_request` method, and parsing the response with the `read_response`
method.

### Environment variables

The variables can be set programmatically in your Ruby programs like

```ruby
# from a ruby script
ENV['CLAMD_UNIX_SOCKET'] = '/some/path'

# Now the defaults are changed for any new ClamAV::Client instantiation
```

or by setting the variables before starting the Ruby process:

```
# from the command-line
export CLAMD_UNIX_SOCKET = '/some/path'
ruby my_program.rb
# or
CLAMD_UNIX_SOCKET = '/some/path' ruby my_program.rb
```

Please note that setting the `CLAMD_TCP_*` variables will have the precedence
over the `CLAMD_UNIX_SOCKET`.

#### CLAMD_UNIX_SOCKET

Sets the socket path of the ClamAV daemon.

#### CLAMD_TCP_HOST and CLAMD_TCP_PORT

Sets the host and port of the ClamAV daemon.

## Contributing

1. Fork it ( https://github.com/franckverrot/clamav-client/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
