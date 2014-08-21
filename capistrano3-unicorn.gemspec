lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "capistrano3-rainbows"
  gem.version       = '0.2.1'
  gem.authors       = ["Matthew Lineen"]
  gem.email         = ["matthew@lineen.com"]
  gem.description   = "Rainbows specific Capistrano tasks"
  gem.summary       = "Rainbows specific Capistrano tasks"
  gem.homepage      = "https://github.com/tablexi/capistrano3-rainbows"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'capistrano', '~> 3.1', '>= 3.1.0'
end
