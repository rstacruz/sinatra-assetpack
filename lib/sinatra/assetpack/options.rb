module Sinatra
  module AssetPack
    class Options
      def initialize(app, &blk)
        @app             = app
        @js_compression  = :jsmin
        @css_compression = :sass
        @output_path     = app.public

        @js_compression_options  = Hash.new
        @css_compression_options = Hash.new

        reset!

        # Defaults!
        serve '/css',    :from => 'app/css'
        serve '/js',     :from => 'app/js'
        serve '/images', :from => 'app/images'

        instance_eval &blk  if block_given?
      end

      # =====================================================================
      # DSL methods

      def serve(path, options={})
        raise Error  unless options[:from]
        return  unless File.directory?(File.join(app.root, options[:from]))

        @served[path] = options[:from]
      end

      # Undo defaults.
      def reset!
        @served   = Hash.new
        @packages = Hash.new
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

      attr_reader   :app        # Sinatra::Base instance
      attr_reader   :packages   # Hash, keys are "foo.js", values are Packages
      attr_reader   :served     # Hash, paths to be served

      attr_accessor :js_compression    # Symbol, compression method for JS
      attr_accessor :css_compression   # Symbol, compression method for CSS
      attr_accessor :output_path       # '/public'

      attr_accessor :js_compression_options   # Hash
      attr_accessor :css_compression_options  # Hash
      
      # =====================================================================
      # Stuff

      attr_reader :served

      def build!(&blk)
        session = Rack::Test::Session.new app

        packages.each { |_, pack|
          out = session.get(pack.path).body

          write pack.path, out, &blk
          write pack.production_path, out, &blk
        }
      end

      def write(path, output)
        require 'fileutils'

        path = File.join(@output_path, path)
        yield path  if block_given?

        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.write output }
      end

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

      def cache
        @cache ||= Hash.new
      end

      def reset_cache
        @cache = nil && cache
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
