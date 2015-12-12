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

      def get_file_uri(file, assets, request)
        raise RuntimeError, "You must pass in an asset for a URI to be created for it." if file.nil?

        local = assets.local_file_for file

        if assets.asset_hosts.is_a?(Proc)
          hosts = assets.asset_hosts.call(request)
        else
          hosts = assets.asset_hosts
        end

        dev = assets.app.settings.development?
        file = dev ? file : BusterHelpers.add_cache_buster(file, local)
        file = File.join(request.script_name, file) if request

        if hosts.nil? || dev
          file
        else
          hosts[Digest::MD5.hexdigest(file).to_i(16) % hosts.length]+file
        end
      end
    end
  end
end
