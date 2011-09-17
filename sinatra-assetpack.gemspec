require './lib/sinatra/assetpack/version'

Gem::Specification.new do |s|
  s.name = "sinatra-assetpack"
  s.version = Sinatra::AssetPack.version
  s.summary = %{Asset packager for Sinatra.}
  s.description = %Q{Package your assets for Sinatra.}
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/rstacruz/sinatra-assetpack"
  s.files = `git ls-files`.strip.split("\n")
  s.executables = Dir["bin/*"].map { |f| File.basename(f) }

  s.add_dependency "tilt", ">= 1.3.0"
  s.add_dependency "sinatra"
  s.add_dependency "jsmin"
  s.add_dependency "rack-test"
  s.add_development_dependency "yui-compressor"
  s.add_development_dependency "sass"
  s.add_development_dependency "haml"
  s.add_development_dependency "coffee-script"
  s.add_development_dependency "contest"
  s.add_development_dependency "mocha"
  s.add_development_dependency "stylus"
  s.add_development_dependency "uglifier"
end
