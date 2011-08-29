module Sinatra
  module AssetPack
    class Options
      def initialize(app)
        @app             = app
        @js_compression  = :jsmin
        @css_compression = :sass
        @served          = Hash.new    # Paths to be served
        @packages        = Hash.new
      end

      # =====================================================================
      # DSL methods

      def serve(path, options={})
        raise Error  unless options[:from]
        @served[path] = options[:from]
        # ...
      end

      # Adds some JS packages.
      #
      #     js :foo, '/js', [ '/js/vendor/jquery.*.js' ]
      #
      def js(name, path, files=[])
        @packages["#{name}.js"] = Package.new(self, name, :js, path, files)
      end

      # Adds some CSS packages.
      #
      #     css :app, '/css', [ '/css/screen.css' ]
      #
      def css(name, path, files=[])
        @packages["#{name}.css"] = Package.new(self, name, :css, path, files)
      end

      attr_reader   :app
      attr_accessor :js_compression
      attr_accessor :css_compression
      attr_reader   :packages

      # =====================================================================
      # Stuff

      attr_reader :served

      def files(match=nil)
          # All
          # A buncha tuples
          tuples = @served.map { |prefix, local_path|
            path = File.expand_path(File.join(@app.root, local_path))
            spec = File.join(path, '**', '*')

            Dir[spec].map { |f|
              [ to_uri(f, prefix, path), f ]
            }
          }.flatten.compact

          Hash[*tuples]
      end

      # Returns an array of URI paths of those matching given globs.
      def glob(*match)
        # Only those matching `match`
        keys   = files.keys.select { |f| match.any? { |spec| File.fnmatch?(spec, f) } }
        tuples = keys.map { |key| [key, files[key]] }.flatten
        Hash[*tuples]
      end

    private
      # Returns a URI for a given file
      #     path = '/projects/x/app/css'
      #     to_uri('/projects/x/app/css/file.sass', '/styles', path) => '/styles/file.css'
      #
      def to_uri(f, prefix, path)
        fn = (prefix + f.gsub(path, '')).squeeze('/')

        # Switch the extension ('x.sass' => 'x.css')
        file_ext = File.extname(fn).to_s[1..-1]
        out_ext  = AssetPack.tilt_formats[file_ext]

        fn = fn.gsub(/\.#{file_ext}$/, ".#{out_ext}")  if file_ext && out_ext

        fn
      end
    end
  end
end
