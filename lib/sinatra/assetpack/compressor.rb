module Sinatra
  module AssetPack
    module Compressor
      extend self

      # Compresses a given string.
      #
      #     compress File.read('x.js'), :js, :jsmin
      #
      def compress(str, type, engine=nil, options={})
        engine ||= 'jsmin'   if type == :js
        engine ||= 'simple'  if type == :css

        key  = :"#{type}/#{engine}"
        meth = compressors[key]
        return str  unless meth

        meth[str, options]
      end

      def compressors
        @compressors ||= {
          :'js/jsmin'    => method(:jsmin),
          :'js/yui'      => method(:yui_js),
          :'js/closure'  => method(:closure_js),
          :'css/sass'    => method(:sass),
          :'css/yui'     => method(:yui_css),
          :'css/simple'  => method(:simple_css),
        }
      end

      # =====================================================================
      # Compressors

      def jsmin(str, options={})
        require 'jsmin'
        JSMin.minify str
      end

      def sass(str, options={})
        Tilt.new("scss", {:style => :compressed}) { str }.render
      rescue LoadError
        simple_css str
      end

      def yui_css(str, options={})
        require 'yui/compressor'
        YUI::CssCompressor.new.compress(str)
      rescue Errno::ENOENT
        sass str
      end

      def yui_js(str, options={})
        require 'yui/compressor'
        YUI::JavaScriptCompressor.new(options).compress(str)
      rescue LoadError
        jsmin str
      end

      def simple_css(str, options={})
        str.gsub! /[ \r\n\t]+/m, ' '
        str.gsub! %r{ *([;\{\},:]) *}, '\1'
      end

      def closure_js(str, options={})
        require 'net/http'
        require 'uri'

        response = Net::HTTP.post_form(URI.parse('http://closure-compiler.appspot.com/compile'), {
          'js_code' => str,
          'compilation_level' => options[:level] || "ADVANCED_OPTIMIZATIONS",
          'output_format' => 'text',
          'output_info' => 'compiled_code'
        })

        response.body
      end

      # For others
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
