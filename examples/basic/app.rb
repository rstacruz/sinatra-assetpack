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

    prebuild true
  end

  get '/' do
    erb :index
  end
end

if __FILE__ == $0
  App.run!
end
