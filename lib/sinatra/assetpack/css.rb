require 'uri'

module Sinatra
  module AssetPack
    module Css
      def self.preproc(source, assets)
        source.gsub(/url\((["']?)(.*?)(["']?)\)/) do |match|
          quote_start=$1
          content_in_quotes=$2
          quote_end=$3
          next match if content_in_quotes =~ /^data:/ # skip if its data_uri

          uri = URI.parse(content_in_quotes)

          # Not a valid complete url
          next match if uri.path.nil?

          # Not found in served assets
          local = assets.local_file_for(uri.path)
          next match if local.nil?

          asset_url = build_url(assets, local, uri)
          "url(#{quote_start}#{asset_url}#{quote_end})"
        end
      end

      def self.build_url(assets, local, uri)
        if uri.query && uri.query.include?('embed')
          build_data_uri(local)
        else
          serve = URI(HtmlHelpers.get_file_uri(uri.path, assets))
          serve.query = uri.query
          serve.fragment = uri.fragment
          serve.to_s
        end
      end

      def self.build_data_uri(file)
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
