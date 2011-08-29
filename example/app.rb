$:.unshift File.expand_path('../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'
require 'coffee-script'

class Main < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :views, "#{root}/app/views"

  register Sinatra::AssetPack

  disable :raise_exceptions
  enable  :dump_errors

  assets {
    #serve '/js',     from: 'app/js'
    serve '/css',    from: 'app/css'
    serve '/images', from: 'app/images'

    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/assets/**/*.js',
      '/js/hi.js',
      '/js/hell*.js'
    ]

    css :application, '/css/application.css', [
      '/css/screen.css'
    ]

    css :js2, '/css/js2.css', [
      '/css/js2c.css'
    ]

    css :sq, '/css/sq.css', [
      '/css/sqwishable.css'
    ]
  }

  get '/index.html' do
    haml :index
  end

  get '/helpers/css' do
    haml %{
      != css :application, :media => 'screen'
    }.strip
  end
end

