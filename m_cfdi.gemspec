# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'm_cfdi/version'

Gem::Specification.new do |spec|
  spec.name          = "m_cfdi"
  spec.version       = MCFDI::VERSION
  spec.authors       = ["Yaser Almasri"]
  spec.email         = ["info@masys.co"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{CFDI Mexico.}
  spec.description   = %q{CFDI Mexico, To generate XML files from invoices of Mexico, Comprobantes Fiscales Digitales por Internet}
  spec.homepage      = "https://github.com/MaSys/m_cfdi"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'nokogiri', '~> 1.6'
  spec.add_dependency 'number_to_words', '~> 1.2'
  spec.add_dependency 'rqrcode_png', '~> 0.1'
end
