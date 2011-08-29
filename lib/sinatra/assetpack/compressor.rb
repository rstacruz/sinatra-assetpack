module Sinatra
  module AssetPack
    module Compressor
      extend self

      # Compresses a given string.
      #
      #     compress File.read('x.js'), :js, :jsmin
      #
      def compress(str, type, engine=nil)
        engine ||= 'jsmin'   if type == :js
        engine ||= 'sass'    if type == :css

        key  = :"#{type}/#{engine}"
        meth = compressors[key]
        return str  unless meth

        puts meth[str]
        meth[str]
      end

      def compressors
        @compressors ||= {
          :'js/jsmin' => method(:jsmin),
          :'css/sass' => method(:sass)
        }
      end

      # =====================================================================
      # Compressors

      def jsmin(str)
        require 'jsmin'
        JSMin.minify str
      end

      def sass(str)
        Tilt.new("scss", {:style => :compressed}) { str }.render
      end
    end
  end
end
