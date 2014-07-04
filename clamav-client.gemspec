# coding: utf-8
$:<< 'lib'

Gem::Specification.new do |spec|
  spec.name          = "clamav-client"
  spec.version       = "3.0.0"
  spec.authors       = ["Franck Verrot"]
  spec.email         = ["franck@verrot.fr"]
  spec.summary       = %q{ClamAV::Client connects to a Clam Anti-Virus clam daemon and send commands.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/franckverrot/clamav-client"
  spec.license       = "GPLv3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "minitest"
end
