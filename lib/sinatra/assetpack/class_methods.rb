module Sinatra
  module AssetPack
    # Class methods that will be given to the Sinatra application.
    module ClassMethods
      # Sets asset options, or gets them
      def assets(&blk)
        @options ||= Options.new(self)

        if block_given?
          @options.instance_eval &blk
          self.assets_initialize!
        end

        @options
      end

      def assets_initialize!
        add_compressed_routes!
        add_individual_routes!
      end

      def add_compressed_routes!
        assets.packages.each do |name, package|
          get package.route_regex do
            content_type package.type
            last_modified package.mtime

            package.minify
          end
        end
      end

      # Add the routes for the individual files.
      def add_individual_routes!
        assets.served.each do |path, from|
          get "/#{path}/*".squeeze('/') do |file|
            fmt = File.extname(file)[1..-1]

            # Sanity checks
            pass unless AssetPack.supported_formats.include?(fmt)
            fn = asset_path_for(file, from)  or pass

            # Send headers
            content_type fmt.to_sym
            last_modified File.mtime(fn).to_i

            format = File.extname(fn)[1..-1]

            if AssetPack.supported_formats.include?(format)
              # It's a raw file, just send it
              not_found  unless format == fmt
              send_file fn
            else
              # Dynamic file
              not_found unless AssetPack.tilt_formats[format] == fmt
              render format.to_sym, File.read(fn)
            end
          end
        end

      end
    end
  end
end
