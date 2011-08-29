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

        meth[str]
      end

      def compressors
        @compressors ||= {
          :'js/jsmin'    => method(:jsmin),
          :'js/yui'      => method(:yui_js),
          :'css/sass'    => method(:sass),
          :'css/yui'     => method(:yui_css),
          :'css/simple'  => method(:simple_css),
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
      rescue LoadError
        simple_css str
      end

      def yui_css(str)
        sys :css, str, "yuicompressor %f"
      rescue Errno::ENOENT
        sass str
      end

      def yui_js(str)
        sys :js, str, "yuicompressor %f"
      rescue Errno::ENOENT
        jsmin str
      end

      def simple_css(str)
        str.gsub! /[ \r\n\t]+/m, ' '
        str.gsub! %r{ *([;\{\},:]) *}, '\1'
      end

      def sys(type, str, cmd)
        t = Tempfile.new ['', ".#{type}"]
        t.write(str)
        t.close

        output = `#{cmd.gsub('%f', t.path)}`
        FileUtils.rm t

        output
      end
    end
  end
end
