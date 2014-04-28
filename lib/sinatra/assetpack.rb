require 'rack/test'
require 'sinatra'

module Sinatra
  module AssetPack
    def self.registered(app)
      app.helpers Helpers
    end

    # Returns a list of formats that can be served.
    # Anything not in this list will be rejected.
    def self.supported_formats
      @supported_formats ||= %w(css js png jpg gif svg otf eot ttf woff htc ico)
    end

    # Returns a map of what MIME format each Tilt type returns.
    def self.tilt_formats
      @formats ||= begin
        hash = Hash.new
        Tilt.mappings.each do |format, (engine, _)|
          # @todo Remove when fix is merged in tilt
          # https://github.com/rtomayko/tilt/pull/206
          next if engine.nil? 
          case engine.default_mime_type
          when 'text/css' then hash[format] = 'css'
          when 'application/javascript' then hash[format] = 'js'
          end
        end

        hash
      end
    end

    # Returns the inverse of tilt_formats.
    def self.tilt_formats_reverse
      re = Hash.new { |h, k| h[k] = Array.new }
      formats.each { |tilt, out| re[out] << tilt }
      out
    end

    # Clear Tilt::Cache (used primarily for tests)
    def self.clear_tilt_cache!(cache, app)
      cache.clear
      #app.clear_tilt_cache = false  # Maybe it can be an option on app we can enable/disable?
    end

    PREFIX = File.dirname(__FILE__)

    autoload :ClassMethods,  "#{PREFIX}/assetpack/class_methods"
    autoload :Options,       "#{PREFIX}/assetpack/options"
    autoload :Builder,       "#{PREFIX}/assetpack/builder"
    autoload :Helpers,       "#{PREFIX}/assetpack/helpers"
    autoload :HtmlHelpers,   "#{PREFIX}/assetpack/html_helpers"
    autoload :BusterHelpers, "#{PREFIX}/assetpack/buster_helpers"
    autoload :Engine,        "#{PREFIX}/assetpack/engine"
    autoload :Package,       "#{PREFIX}/assetpack/package"
    autoload :Compressor,    "#{PREFIX}/assetpack/compressor"
    autoload :Image,         "#{PREFIX}/assetpack/image"
    autoload :Css,           "#{PREFIX}/assetpack/css"
    autoload :Configurator,  "#{PREFIX}/assetpack/configurator"

    include ClassMethods

    Error = Class.new(StandardError)

    require "#{PREFIX}/assetpack/version"
  end

  # Autoload in Sinatra classic mode
  register AssetPack
end
