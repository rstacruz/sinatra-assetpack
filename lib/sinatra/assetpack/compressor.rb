module Sinatra
  module AssetPack
    module Compressor
      extend self

      # Compresses a given string.
      #
      #     compress File.read('x.js'), :js, :jsmin
      #
      def compress(str, type, engine=nil, options={})
        # Use defaults if no engine is given.
        return fallback(str, type, options)  if engine.nil?

        # Ensure that the engine exists.
        klass = compressors[[type, engine]]
        raise Error, "Engine #{engine} (#{type}) doesn't exist."  unless klass

        # Ensure that the engine can support that type.
        engine = klass.new
        raise Error, "#{klass} does not support #{type.upcase} compression."  unless engine.respond_to?(type)

        # Build it using the engine, and fallback to defaults if it fails.
        output   = engine.send type, str, options
        output ||= fallback(str, type, options)  unless options[:no_fallback]
        output
      end

      # Compresses a given string using the default engines.
      def fallback(str, type, options)
        if type == :js
          compress str, :js, :jsmin, :no_fallback => true
        elsif type == :css
          compress str, :css, :simple, :no_fallback => true
        end
      end

      def compressors
        @compressors ||= Hash.new
      end

      def register(type, engine, meth)
        compressors[[type, engine]] = meth
      end
    end

    require "#{AssetPack::PREFIX}/assetpack/engines/simple"
    require "#{AssetPack::PREFIX}/assetpack/engines/jsmin"
    require "#{AssetPack::PREFIX}/assetpack/engines/yui"
    require "#{AssetPack::PREFIX}/assetpack/engines/sass"
    require "#{AssetPack::PREFIX}/assetpack/engines/less"
    require "#{AssetPack::PREFIX}/assetpack/engines/sqwish"
    require "#{AssetPack::PREFIX}/assetpack/engines/closure"
    require "#{AssetPack::PREFIX}/assetpack/engines/uglify"
  end
end
