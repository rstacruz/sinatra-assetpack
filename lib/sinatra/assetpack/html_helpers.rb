module Sinatra
  module AssetPack
    module HtmlHelpers
      extend self

      def e(str)
        Rack::Utils.escape_html str
      end

      def kv(hash)
        hash.map { |k, v| " #{e k}='#{e v}'" }.join('')
      end
    end
  end
end
