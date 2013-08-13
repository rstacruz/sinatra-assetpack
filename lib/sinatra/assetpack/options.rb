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
      include Builder
      include Configurator

      def initialize(app, &blk)
        unless app.root?
          raise Error, "Please set :root in your Sinatra app."
        end

        @app             = app
        @js_compression  = :jsmin
        @css_compression = :simple
        @reload_files_cache = true

        begin
          @output_path   = app.public
        rescue NoMethodError
          @output_path   = app.public_folder
        end

        @js_compression_options  = Hash.new
        @css_compression_options = Hash.new
        @dynamic_asset_cache     = Hash.new

        @ignored = Array.new

        reset!

        # Defaults!
        serve '/css',    :from => 'app/css'     rescue Errno::ENOTDIR
        serve '/js',     :from => 'app/js'      rescue Errno::ENOTDIR
        serve '/images', :from => 'app/images'  rescue Errno::ENOTDIR

        ignore '.*'
        ignore '_*'

        blk.arity <= 0 ? instance_eval(&blk) : yield(self)  if block_given?
      end

      # =====================================================================
      # DSL methods

      def serve(path, options={})
        unless from = options[:from]
          raise ArgumentError, "Parameter :from is required" 
        end

        expanded = expand_from(from)

        unless File.directory? expanded
          raise Errno::ENOTDIR, expanded
        end

        @served[path] = from
        @reload_files_cache = true
      end

      # Undo defaults.
      def reset!
        @served   = Hash.new
        @packages = Hash.new
        @reload_files_cache = true
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
      attrib :cache_dynamic_assets # Bool

      def expires(*args)
        if args.empty?
          @expires
        else
          @expires = args
        end
      end

      def js_compression(name=nil, options=nil)
        @js_compression = name unless name.nil?
        @js_compression_options = options if options.is_a?(Hash)
        @js_compression
      end

      def css_compression(name=nil, options=nil)
        @css_compression = name unless name.nil?
        @css_compression_options = options if options.is_a?(Hash)
        @css_compression
      end

      # =====================================================================
      # Stuff

      attr_reader :served

      # Caches the packages.
      def cache!(&blk)
        return if app.reload_templates

        session = Rack::Test::Session.new app
        packages.each { |_, pack|
          yield pack.path if block_given?
          session.get(pack.path)
        }
      end

      def served?(path)
        !! local_file_for(path)
      end

      # Returns the local file for a given URI path.
      # Returns nil if a file is not found.
      def local_file_for(request)
        request = request.squeeze('/')
        serve_path, from = served.detect { |path, _| request.start_with?(path) }

        return if !from

        path = File.join(expand_from(from), request.sub(serve_path, ''))
        return if !File.file?(path)

        path
      end

      # Returns the local file for a given URI path. (for dynamic files)
      # Returns nil if a file is not found.
      def dyn_local_file_for(request, from)
        file = request.dup
        extension = File.extname(request)
        # Remove extension
        file.gsub!(/#{extension}$/, "")
        # Remove cache-buster (/js/app.28389 => /js/app)
        file.gsub!(/\.[a-f0-9]{32}$/, "")

        matches = Dir[File.join(expand_from(from), "#{file}.*")]

        # Fix for filenames with dots (can't do this with glob)
        matches = matches.select { |f| f =~ /#{file}\.[^.]+$/ }

        # Sort static file match, weighting exact file extension matches
        # first, then registered Tilt formats
        matches.sort! do |candidate, _|
          cfmt = File.extname(candidate)[1..-1]
          efmt = extension[1..-1]
          (cfmt == efmt or AssetPack.tilt_formats[cfmt] == efmt) ? -1 : 1
        end
        matches.first
      end

      # Returns the files as a hash.
      def files(match=nil)
        return @files unless @reload_files_cache

        # All
        # A buncha tuples
        tuples = @served.map { |prefix, local_path|
          path = File.expand_path(File.join(@app.root, local_path))
          spec = File.join(path, '**', '*')

          Dir[spec].map { |f|
            [ to_uri(f, prefix, path), f ]  unless File.directory?(f)
          }
        }.flatten.compact

        @reload_files_cache = false
        @files = Hash[*tuples]
      end

      # Returns an array of URI paths of those matching given globs.
      #
      #     glob('spec')
      #     glob(['spec1', 'spec2' ...])
      #
      def glob(match)
        paths = Array.new(match) # Force array-ness

        paths.map! do |spec|
          if spec.include?('*')
            files.select do |file, _|
              # Dir#glob like source matching
              File.fnmatch?(spec, file, File::FNM_PATHNAME | File::FNM_DOTMATCH)
            end.sort
          else
            [spec, files[spec]]
          end
        end

        Hash[*paths.flatten]
      end

      # Fetches the contents of a dynamic asset. If `cache_dynamic_assets` is set,
      # check file mtime and potentially return contents from cache instead of re-compiling.
      # Yields to a block to compile & render the asset.
      def fetch_dynamic_asset(path)
        return yield unless cache_dynamic_assets

        mtime = File.mtime(path)
        cached_mtime, contents = @dynamic_asset_cache[path]

        if cached_mtime.nil? || mtime != cached_mtime
          @dynamic_asset_cache[path] = [mtime, yield]
          @dynamic_asset_cache[path][1]
        else
          contents
        end
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

      def expand_from(from)
        if from.start_with?('/')
          from
        else
          File.join(app.root, from)
        end
      end
    end
  end
end
