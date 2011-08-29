$:.unshift File.expand_path('../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  assets do
    js :main, '/js/main.js', [
      '/js/vendor/*.js',
      '/js/app.js'
    ]

    css :main, '/css/main.css', [
      '/css/*.css'
    ]
  end

  get '/' do
    erb :index
  end
end

if __FILE__ == $0
  App.run!
end
