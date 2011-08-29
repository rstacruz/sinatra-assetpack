module Sinatra
  module AssetPack
    module BusterHelpers
      extend self
      # Returns the cache buster suffix for given file(s).
      # This implementation somewhat obfuscates the mtime to not reveal deployment dates.
      def cache_buster_hash(*files)
        i = files.map { |f| File.mtime(f).to_i }.max
        (i * 4567).to_s.reverse[0...6]
      end

      # Adds a cache buster for the given path.
      #
      #   add_cache_buster('/images/email.png', '/var/www/x/public/images/email.png')
      #
      def add_cache_buster(path, *files)
        path.gsub(/(\.[^.]+)$/) { |ext| ".#{cache_buster_hash *files}#{ext}" }
      end
    end
  end
end
