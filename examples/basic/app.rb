$:.unshift File.expand_path('../../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  assets do
    #js_compression :closure
    js_compression :uglify

    js :main, '/js/main.js', [
      '/js/vendor/*.js',
      '/js/app.js'
    ]

    css :main, [
      '/css/*.css'
    ]

    # The second parameter here is optional (see above).
    # It will default to '/css/#{name}.css'.
    css :more, '/css/more.css', [
      '/css/more/*.css'
    ]

    prebuild false

    # Can set this as an environment variable like "HOST" or "CDN_HOST"
    # This will add the domain name to the beginning of compiled assets
    # Useful if you need to serve production assets from a CDN
    asset_hosts [
      '//cdn-0.example.org',
      '//cdn-1.example.org',
      '//cdn-2.example.org',
      '//cdn-3.example.org'
    ]

  end

  get '/' do
    erb :index
  end
end

if __FILE__ == $0
  App.run!
end
