module Sinatra
  module AssetPack
    module BusterHelpers
      extend self
      # Returns the MD5 for all of the files concatenated together
      def cache_buster_hash(*files)
        content = files.sort.map { |f| File.read(f).to_s if f.is_a?(String) && File.file?(f) }.compact
        Digest::MD5.hexdigest(content.join) if content.any?
      end

      # Returns the maximum mtime for a given list of files.
      # It will return nil if none of them are found.
      def mtime_for(files)
        files.map { |f| File.mtime(f).to_i  if f.is_a?(String) && File.file?(f) }.compact.max
      end

      # Adds a cache buster for the given path.
      #
      # The 2nd parameter (and beyond) are the files to take mtime from.
      # If the files are not found, the paths will be left as they are.
      #
      #   add_cache_buster('/images/email.png', '/var/www/x/public/images/email.png')
      #
      def add_cache_buster(path, *files)
        hash = cache_buster_hash *files

        if hash
          path.gsub(/(\.[^.]+)$/) { |ext| ".#{hash}#{ext}" }
        else
          path
        end
      end
    end
  end
end
