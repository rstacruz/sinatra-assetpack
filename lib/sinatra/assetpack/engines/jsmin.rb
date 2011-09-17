module Sinatra::AssetPack
  class JsminEngine < Engine
    def js(str, options={})
      require 'jsmin'
      JSMin.minify str
    end
  end

  Compressor.register :js, :jsmin, JsminEngine
end
