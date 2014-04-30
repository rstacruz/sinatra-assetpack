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
  desc "Precompile all assets"
  task :precompile => ['precompile:packages', 'precompile:files']

  namespace :precompile do
    desc "Precompile packages only"
    task :packages do
      puts "Precompiling packages ..."
      app.assets.build_packages! do |file|
        puts "+ #{file.gsub(Dir.pwd, '')}"
      end
    end

    desc "Precompile files only"
    task :files do
      puts "Precompiling files ..."
      app.assets.build_files! do |file|
        puts "+ #{file.gsub(Dir.pwd, '')}"
      end
    end
  end

  # For backwards compatibility
  task :build do
    puts "WARNING: assetpack:build is deprecated. Use assetpack:precompile"
    Rake::Task["assetpack:precompile"].invoke
  end
end
