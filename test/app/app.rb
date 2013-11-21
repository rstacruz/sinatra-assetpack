$:.unshift File.expand_path('../../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'
require 'coffee-script'
require 'sass'
require 'haml'

class Main < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :views, "#{root}/app/views"

  register Sinatra::AssetPack

  enable  :raise_errors
  disable :show_exceptions

  assets {
    serve '/js',     :from => 'app/js'
    serve '/css',    :from => 'app/css'
    serve '/images', :from => 'app/images'
    serve '/fonts',    :from => 'app/fonts'
    serve '/packages',    :from => 'app/packages'

    js :js_package, '/packages/js_package.js', [
      '/packages/a_package/package.js',
    ]

    js :skitch, '/skitch.js', [
      '/js/hi.js',
    ]

    js :app, '/js/app.js', [
      '/js/vendor/**/*.js',
      '/js/assets/**/*.js',
      '/js/hi.js',
      '/js/hell*.js'
    ]

    js :encoding, '/js/encoding.js', [
      '/js/yoe.js',
      '/js/helloe.js'
    ]

    css :css_package, '/packages/css_package.css', [
      '/packages/a_package/package.css',
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

    css :redundant, [
      '/css/scre*.css',
      '/css/scre*.css',
      '/css/scre*.css',
      '/css/screen.css'
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

  get '/helpers/email' do
    haml %{
      != img '/images/email.png'
    }.strip
  end
end

