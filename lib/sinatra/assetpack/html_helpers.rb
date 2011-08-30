module Sinatra
  module AssetPack
    module HtmlHelpers
      extend self

      def e(str)
        re = Rack::Utils.escape_html str
        re = re.gsub("&#x2F;", '/')  # Rack sometimes insists on munging slashes in Ruby 1.8.
        re
      end

      def kv(hash)
        hash.map { |k, v| " #{e k}='#{e v}'" }.join('')
      end
    end
  end
end
