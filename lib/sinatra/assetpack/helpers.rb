module Sinatra
  module AssetPack
    module Helpers
      def css(*args)
        show_asset_pack :css, *args
      end

      def js(*args)
        show_asset_pack :js, *args
      end

      def img(src, options={})
        attrs = { :src => image_path(src) }
        attrs = attrs.merge(options)

        "<img#{HtmlHelpers.kv attrs} />"
      end

      def image_path(src)
        if src =~ /\A(http|https)\:\/\//
          src
        else
          HtmlHelpers.get_file_uri(src, settings.assets, request)
        end
      end

      def show_asset_pack(type, *args)
        names = Array.new
        while args.first.is_a?(Symbol)
          names << args.shift
        end

        options = args.shift  if args.first.is_a?(Hash)

        names.map { |name|
          show_one_asset_pack type, name, (options || Hash.new)
        }.join "\n"
      end

      def show_one_asset_pack(type, name, options={})
        pack = settings.assets.packages["#{name}.#{type}"]
        return ""  unless pack

        if settings.environment.to_sym == :production
          pack.to_production_html(request, options)
        else
          pack.to_development_html(request, options)
        end
      end

      def asset_filter_css(str)
        Css.preproc(str, settings.assets, request)
      end

      def asset_path_for(file, from)
        settings.assets.dyn_local_file_for file, from
      end

      def assets_expires
        if settings.assets.expires.nil?
          expires 86400*30, :public
        else
          expires *settings.assets.expires
        end
      end

    end
  end
end
