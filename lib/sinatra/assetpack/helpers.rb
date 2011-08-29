module Sinatra
  module AssetPack
    module Helpers
      def css(name, options={})
        show_asset_pack :css, name, options
      end

      def js(name, options={})
        show_asset_pack :js, name, options
      end

      def img(src, options={})
        attrs = { :src => src }.merge(options)

        local = settings.assets.local_file_for src
        if local
          i = Image.new(local)
          attrs[:src] = BusterHelpers.add_cache_buster(src, local)
          if i.dimensions?
            attrs[:width]  ||= i.width
            attrs[:height] ||= i.height
          end
        end

        "<img#{HtmlHelpers.kv attrs} />"
      end

      def show_asset_pack(type, name, options={})
        pack = settings.assets.packages["#{name}.#{type}"]
        return ""  unless pack

        if settings.production?
          pack.to_production_html options
        else
          pack.to_development_html options
        end
      end

      # These below should be refactored into a new module

      # From a URI path (/js/app.js), get the file for it.
      # asset_path_for ('/js/app.js', 'app/js')
      def asset_path_for(file, from)
        # Remove extension
        file = $1  if file =~ /^(.*)(\.[^\.]+)$/

        # Remove cache-buster (/js/app.28389.js => /js/app)
        file = $1  if file =~ /^(.*)\.[0-9]+$/

        Dir[File.join(settings.root, from, "#{file}.*")].first
      end
    end
  end
end
