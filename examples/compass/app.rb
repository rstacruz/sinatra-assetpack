$:.unshift File.expand_path('../../../lib', __FILE__)

require 'sinatra/base'
require 'sinatra/assetpack'
require 'compass'
require 'sinatra/support'

Encoding.default_external = 'utf-8'  if defined?(::Encoding)

class App < Sinatra::Base
  disable :show_exceptions
  enable  :raise_exceptions

  set :root, File.dirname(__FILE__)

  # This is a convenient way of setting up Compass in a Sinatra
  # project without mucking around with load paths and such.
  register Sinatra::CompassSupport

  # ### Compass sprite configuration
  # Skip this section if you don't need sprite images.
  #
  # Configure Compass so it knows where to look for sprites.  This tells
  # Compass to look for images in `app/images`, dump sprite images in the same
  # folder, and link to it with HTTP images path.
  #
  c = Compass.configuration
  c.project_path     = root
  c.images_dir       = "app/images"
  c.http_generated_images_path = "/images"

  # Asset Pack.
  register Sinatra::AssetPack
  assets do
    css :main, ['/css/*.css']
  end

  # If you wish to put your scss files into a folder that is not 'app/css',
  # you need to add some more configurations (refer to 
  #
  # https://github.com/chriseppstein/compass/wiki/Sinatra-Integration
  #
  # for more infos)
  #
  # stylesheets_dir = 'assets/stylesheets' # Change at your desire
  # c.sass_dir = stylesheets_dir
  # set :sass, { :load_paths => Compass.sass_engine_options[:load_paths] + [ stylesheets_dir ] }
  # assets do
  #   serve '/css', :from => stylesheets_dir
  # end

  get '/' do
    erb :index
  end
end

if __FILE__ == $0
  App.run!
end
