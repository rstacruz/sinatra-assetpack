require './lib/sinatra/assetpack/version'

Gem::Specification.new do |s|
  s.name = 'sinatra-assetpack'
  s.version = Sinatra::AssetPack::VERSION
  s.summary = %{Asset packager for Sinatra.}
  s.description = %Q{Package your assets for Sinatra.}
  s.authors = ['Rico Sta. Cruz', 'Jean-Philippe Doyle']
  s.licenses ['MIT']
  s.email = ['rico@sinefunc.com']
  s.homepage = 'http://github.com/rstacruz/sinatra-assetpack'
  s.files = `git ls-files`.strip.split("\n")
  s.executables = Dir['bin/*'].map { |f| File.basename(f) }
  s.cert_chain  = ['certs/j15e.pem']
  s.signing_key = File.expand_path('~/.gem/private_key.pem') if $0 =~ /gem\z/

  s.add_dependency 'backports'
  s.add_dependency 'jsmin'
  s.add_dependency 'rack-test'
  s.add_dependency 'sinatra'
  s.add_dependency 'tilt', '>= 1.3.0'

  # Supported preprocessors
  s.add_development_dependency 'coffee-script'
  s.add_development_dependency 'contest'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'less'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'stylus'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'yui-compressor'

  # For gem tests
  s.add_development_dependency 'rake'
  s.add_development_dependency 'mocha'

  # For gem release mangement
  s.add_development_dependency 'gem-release'

end
