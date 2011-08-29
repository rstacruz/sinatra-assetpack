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

  s.add_dependency "sinatra"
  s.add_dependency "jsmin"
end
