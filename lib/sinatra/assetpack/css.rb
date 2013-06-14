require 'uri'

module Sinatra
  module AssetPack
    module Css
      def self.preproc(str, assets)
        str.gsub(/url\((["']?)(?!["']?data:)(.*?)(["']?)\)/) { |url|
          css_url = URI.parse($2)
          file = css_url.path
          options = css_url.query
          local = assets.local_file_for file

          url = if local
            if options.to_s.include?('embed')
              to_data_uri(local)
            else
              url = HtmlHelpers.get_file_uri(file, assets)
              serve = URI(url)
              serve.query = css_url.query
              serve.fragment = css_url.fragment
              serve.to_s
            end
          else
            $2
          end

          "url(#{$1}#{url}#{$3})"
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
