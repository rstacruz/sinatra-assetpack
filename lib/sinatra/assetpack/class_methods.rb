module Sinatra
  module AssetPack
    # Class methods that will be given to the Sinatra application.
    module ClassMethods
      # Sets asset options, or gets them
      def assets(&blk)
        @options ||= Options.new(self, &blk)
        self.assets_initialize!  if block_given?

        @options
      end

      def assets_initialize!
        add_compressed_routes!
        add_individual_routes!

        # Cache the built files.
        if assets.prebuild && !reload_templates
          assets.cache! { |file| $stderr.write "** Building #{file}...\n" }
        end
      end

      # Add routes for the compressed versions
      def add_compressed_routes!
        assets.packages.each do |name, package|
          get package.route_regex do
            if defined?(settings.assets.app.clear_tilt_cache) && settings.assets.app.clear_tilt_cache
              AssetPack.clear_tilt_cache!(@template_cache, settings.assets.app)
            end
            
            mtime, contents = @template_cache.fetch(package.path) {
              [ package.mtime, package.minify ]
            }

            content_type package.type
            last_modified mtime
            assets_expires
            contents
          end
        end
      end

      # Add the routes for the individual files.
      def add_individual_routes!
        assets.served.each do |path, from|
          get %r{#{"^/#{path}/".squeeze('/')}(.*)$} do |file|
            fmt = File.extname(file)[1..-1]

            if file =~ /(.*)\.([a-f0-9]*{16,})\.(.*)/
              clean_file = "#{$1}.#{$3}"
              requested_hash = $2
            else
              clean_file = file
            end
            
            # Sanity checks
            pass unless AssetPack.supported_formats.include?(fmt)
            
            fn = asset_path_for(clean_file, from) or pass
            
            pass if settings.assets.ignored?("#{path}/#{clean_file}")

            # Send headers
            content_type fmt.to_sym
            last_modified File.mtime(fn).to_i
            assets_expires

            format = File.extname(fn)[1..-1]

            if defined?(settings.assets.app.clear_tilt_cache) && settings.assets.app.clear_tilt_cache
              AssetPack.clear_tilt_cache!(@template_cache, settings.assets.app)
            end
            
            if AssetPack.supported_formats.include?(format)
              # Static file
              if fmt == 'css'
                # Matching static file format
                pass unless fmt == File.extname(fn)[1..-1]
                @template_cache.fetch(fn) { asset_filter_css File.read(fn) }
              else
                # It's a raw file, just send it
                send_file fn
              end
            else
              # Dynamic file
              not_found unless AssetPack.tilt_formats[format] == fmt
              
              @template_cache.fetch(fn) {
                out = render format.to_sym, File.read(fn)
                out = asset_filter_css(out)  if fmt == 'css'
                out
              }
            end
          end
        end
      end
    end
  end
end
