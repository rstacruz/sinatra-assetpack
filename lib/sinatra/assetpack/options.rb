module Sinatra
  module AssetPack
    # Assets.
    #
    # == Common usage
    #
    #     SinatraApp.assets {
    #       # dsl stuff here
    #     }
    #
    #     a = SinatraApp.assets
    #
    # Getting options:
    #
    #     a.js_compression
    #     a.output_path
    #
    # Served:
    #
    #     a.served         # { '/js' => '/var/www/project/app/js', ... }
    #                      # (URL path => local path)
    #
    # Packages:
    #
    #     a.packages       # { 'app.css' => #<Package>, ... }
    #                      # (name.type => package instance)
    #
    # Build:
    #
    #     a.build! { |path| puts "Building #{path}" }
    #
    # Lookup:
    #
    #     a.local_path_for('/images/bg.gif')
    #     a.served?('/images/bg.gif')
    #
    #     a.glob(['/js/*.js', '/js/vendor/**/*.js'])
    #     # Returns a HashArray of (local => remote)
    #
    class Options
      include Configurator

      def initialize(app, &blk)
        unless app.root?
          raise Error, "Please set :root in your Sinatra app."
        end

        @app             = app
        @js_compression  = :jsmin
        @css_compression = :simple

        begin
          @output_path   = app.public
        rescue NoMethodError
          @output_path   = app.public_folder
        end

        @js_compression_options  = Hash.new
        @css_compression_options = Hash.new

        @ignored = Array.new

        reset!

        # Defaults!
        serve '/css',    :from => 'app/css'
        serve '/js',     :from => 'app/js'
        serve '/images', :from => 'app/images'

        ignore '.*'
        ignore '_*'

        blk.arity <= 0 ? instance_eval(&blk) : yield(self)  if block_given?
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

      # Ignores a given path spec.
      def ignore(spec)
        if spec[0] == '/'
          @ignored << "#{spec}"
          @ignored << "#{spec}/**"
        else
          @ignored << "**/#{spec}"
          @ignored << "**/#{spec}/**"
        end
      end

      # Makes nothing ignored. Use this if you don't want to ignore dotfiles and underscore files.
      def clear_ignores!
        @ignored  = Array.new
      end

      # Checks if a given path is ignored.
      def ignored?(fn)
        @ignored.any? { |spec| File.fnmatch spec, fn }
      end

      # Adds some JS packages.
      #
      #     js :foo, [ '/js/vendor/jquery.*.js', ... ]
      #     js :foo, '/js/foo.js', [ '/js/vendor/jquery.*.js', ... ]
      #
      def js(name, *args)
        js_or_css :js, name, *args
      end

      # Adds some CSS packages.
      #
      #     css :app, [ '/css/screen.css', ... ]
      #     css :app, '/css/app.css', [ '/css/screen.css', ... ]
      #
      def css(name, *args) #path, files=[])
        js_or_css :css, name, *args
      end

      def js_or_css(type, name, *args)
        # Account for "css :name, '/path/to/css', [ files ]"
        if args[0].is_a?(String) && args[1].respond_to?(:each)
          path, files = args

        # Account for "css :name, [ files ]"
        elsif args[0].respond_to?(:each)
          path  = "/assets/#{name}.#{type}" # /assets/foobar.css by default
          files = args[0]

        else
          raise ArgumentError
        end

        @packages["#{name}.#{type}"] = Package.new(self, name, type, path, files)
      end

      attr_reader   :app        # Sinatra::Base instance
      attr_reader   :packages   # Hash, keys are "foo.js", values are Packages
      attr_reader   :served     # Hash, paths to be served.
                                # Key is URI path, value is local path

      attrib :js_compression    # Symbol, compression method for JS
      attrib :css_compression   # Symbol, compression method for CSS
      attrib :output_path       # '/public'
      attrib :asset_hosts       # [ 'http://cdn0.example.org', 'http://cdn1.example.org' ]

      attrib :js_compression_options   # Hash
      attrib :css_compression_options  # Hash

      attrib :prebuild          # Bool

      def expires(*args)
        if args.empty?
          @expires
        else
          @expires = args
        end
      end

      def js_compression(name=nil, options=nil)
        @js_compression = name  unless name.nil?
        @js_compression_options = options  if options.is_a?(Hash)
        @js_compression
      end

      def css_compression(name=nil, options=nil)
        @css_compression = name  unless name.nil?
        @css_compression_options = options  if options.is_a?(Hash)
        @css_compression
      end

      # =====================================================================
      # Stuff

      attr_reader :served

      def build!(&blk)
        session = Rack::Test::Session.new app

        get = lambda { |path|
          response = session.get(path)
          out      = response.body
          mtime    = Time.parse(response.headers['Last-Modified'])  if response.headers['Last-Modified']

          [ out, mtime ]
        }

        packages.each { |_, pack|
          out, mtime = get[pack.path]

          write pack.path, out, mtime, &blk
          write pack.production_path, out, mtime, &blk
        }

        files.each { |path, local|
          out, mtime = get[path]

          write path, out, mtime, &blk
          write BusterHelpers.add_cache_buster(path, local), out, mtime, &blk
        }
      end

      # Caches the packages.
      def cache!(&blk)
        return false  if app.reload_templates

        session = Rack::Test::Session.new app
        packages.each { |_, pack|
          yield pack.path  if block_given?
          session.get(pack.path)
        }

        true
      end

      def served?(path)
        !! local_file_for(path)
      end

      # Returns the local file for a given URI path.
      # Returns nil if a file is not found.
      def local_file_for(path)
        path = path.squeeze('/')

        uri, local = served.detect { |uri, local| path[0...uri.size] == uri }

        if local
          path = path[uri.size..-1]
          path = File.join app.root, local, path

          path  if File.exists?(path)
        end
      end

      # Returns the local file for a given URI path. (for dynamic files)
      # Returns nil if a file is not found.
      # TODO: consolidate with local_file_for
      def dyn_local_file_for(requested_file, from)
        file = requested_file
        extension = File.extname(requested_file)
        # Remove extension
        file.gsub!(/#{extension}$/, "")
        # Remove cache-buster (/js/app.28389 => /js/app)
        file.gsub!(/\.[a-f0-9]{32}$/, "")
        matches = Dir[File.join(app.root, from, "#{file}.*")]

        # Fix for filenames with dots (can't do this with glob)
        matches.select! { |f| f =~ /#{file}\.[^.]+$/ }

        # Sort static file match, weighting exact file extension matches
        matches.sort! do |f, _| 
          (File.basename(f) == "#{file}#{extension}" || File.extname(f) == extension) ? -1 : 1
        end
        matches.first
      end

      # Writes `public/#{path}` based on contents of `output`.
      def write(path, output, mtime=nil)
        require 'fileutils'

        path = File.join(@output_path, path)
        yield path  if block_given?

        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'wb') { |f| f.write output }

        if mtime
          File.utime mtime, mtime, path
        end
      end

      # Returns the files as a hash.
      def files(match=nil)
          # All
          # A buncha tuples
          tuples = @served.map { |prefix, local_path|
            path = File.expand_path(File.join(@app.root, local_path))
            spec = File.join(path, '**', '*')

            Dir[spec].map { |f|
              [ to_uri(f, prefix, path), f ]  unless File.directory?(f)
            }
          }.flatten.compact

          Hash[*tuples]
      end

      # Returns an array of URI paths of those matching given globs.
      #
      #     glob('spec')
      #     glob(['spec1', 'spec2' ...])
      #     glob('spec', preserve: true)
      #
      # If `preserve` is set to true, it will preserve any specs that are not
      # wildcards that don't match anything.
      #
      def glob(match, options={})

        match = [*match]  # Force array-ness

        paths = match.map { |spec|
          if options[:preserve] && !spec.include?('*')
            spec
          else
            files.keys.select { |f| File.fnmatch?(spec, f) }.sort
          end
        }.flatten

        paths  = paths.uniq
        tuples = paths.map { |key| [key, files[key]] }

        Hash[*tuples.flatten]
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
