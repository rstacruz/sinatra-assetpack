unless defined?(APP_FILE) && defined?(APP_CLASS)
  $stderr.write "Error: Please set APP_FILE and APP_CLASS before setting up AssetPack rake tasks.\n"
  $stderr.write "Example:\n"
  $stderr.write "    APP_FILE  = 'init.rb'\n"
  $stderr.write "    APP_CLASS = 'Application'\n"
  $stderr.write "    require 'sinatra/assetpack/rake'\n"
  $stderr.write "\n"
  exit
end

def class_from_string(str)
  str.split('::').inject(Object) do |mod, class_name|
    mod.const_get(class_name)
  end
end

def app
  require File.expand_path(APP_FILE, Dir.pwd)
  class_from_string(APP_CLASS)
end

namespace :assetpack do
  desc "Build assets"
  task :build do
    app.assets.build! { |file|
      puts "+ #{file.gsub(Dir.pwd, '')}"
    }
  end
end
