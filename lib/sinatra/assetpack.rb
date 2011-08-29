require 'rack/test'

module Sinatra
  module AssetPack
    def self.registered(app)
      unless app.root?
        raise Error, "Please set :root in your Sinatra app."
      end

      app.extend  ClassMethods
      app.helpers Helpers
    end

    # Returns a list of formats that can be served.
    # Anything not in this list will be rejected.
    def self.supported_formats
      @supported_formats ||= %w(css js png jpg gif)
    end

    # Returns a map of what MIME format each Tilt type returns.
    def self.tilt_formats
      @formats ||= {
        'scss' => 'css',
        'sass' => 'css',
        'less' => 'css',
        'coffee' => 'js'
      }
    end

    # Returns the inverse of tilt_formats.
    def self.tilt_formats_reverse
      re = Hash.new { |h, k| h[k] = Array.new }
      formats.each { |tilt, out| re[out] << tilt }
      out
    end

    PREFIX = File.dirname(__FILE__)

    autoload :ClassMethods, "#{PREFIX}/assetpack/class_methods"
    autoload :Options,      "#{PREFIX}/assetpack/options"
    autoload :Helpers,      "#{PREFIX}/assetpack/helpers"
    autoload :Package,      "#{PREFIX}/assetpack/package"
    autoload :Compressor,   "#{PREFIX}/assetpack/compressor"

    Error = Class.new(StandardError)

    require "#{PREFIX}/assetpack/version"
  end
end
