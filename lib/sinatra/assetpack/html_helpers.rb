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

      def get_file_uri(file, assets)
        raise RuntimeError, "You must pass in an asset for a URI to be created for it." if file.nil?

        local = assets.local_file_for file

        hosts = assets.asset_hosts
        dev = assets.app.settings.development?
        file = dev ? file : BusterHelpers.add_cache_buster(file, local)

        if assets.asset_hosts.nil? || dev
          file
        else
          hosts[Digest::MD5.hexdigest(file).to_i(16) % hosts.length]+file
        end
      end
    end
  end
end
