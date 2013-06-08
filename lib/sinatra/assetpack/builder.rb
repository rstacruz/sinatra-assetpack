module Sinatra
  module AssetPack
    module Builder
      def build!(&blk)
        packages.each { |_, pack| build_package!(pack, &blk) }
        files.each { |path, local| build_file!(path, local, &blk) }
      end

      private

      def build_get(path, &blk)
        @session ||= Rack::Test::Session.new app
        @session.get(path)
      end

      def build_package!(pack, &blk)
        response = build_get(pack.path)
        build_write(pack.path, response, &blk)
        build_write(pack.production_path, response, &blk)
      end

      def build_file!(path, local, &blk)
        response = build_get(path)
        build_write(path, response, &blk)
        build_write(BusterHelpers.add_cache_buster(path, local), response, &blk)
      end

      def build_write(path, response, &blk)
        require 'fileutils'

        mtime = Time.parse(response.headers['Last-Modified']) if response.headers['Last-Modified']
        path = File.join(@output_path, path)

        yield path if block_given?

        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, 'wb') { |f| f.write(response.body) }
        File.utime(mtime, mtime, path) if mtime
      end
    end
  end
end