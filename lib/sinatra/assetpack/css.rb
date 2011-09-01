module Sinatra
  module AssetPack
    module Css
      def self.preproc(str, assets)
        str.gsub(/url\(["']?(.*?)["']?\)/) { |url|
          file, options = $1.split('?')
          local = assets.local_file_for file

          url = if local
            if options.to_s.include?('embed')
              to_data_uri(local)
            else
              BusterHelpers.add_cache_buster(file, local)
            end
          else
            file
          end

          "url(#{url})"
        }
      end

      def self.to_data_uri(file)
        require 'base64'

        data = File.read(file)
        ext  = File.extname(file)
        mime = Sinatra::Base.mime_type(ext)
        b64  = Base64.encode64(data).gsub("\n", '')

        "data:#{mime};base64,#{b64}"
      end
    end
  end
end
