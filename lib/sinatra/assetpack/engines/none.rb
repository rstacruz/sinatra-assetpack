module Sinatra::AssetPack
  class NoneEngine < Engine
    def js(str, options={})
      str
    end

    def css(str, options={})
      str
    end
  end

  Compressor.register :js, :none, NoneEngine
  Compressor.register :css, :none, NoneEngine
end
