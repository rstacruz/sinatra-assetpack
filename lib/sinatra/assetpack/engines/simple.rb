module Sinatra::AssetPack
  class SimpleEngine < Engine
    def css(str, options={})
      str.gsub! /[ \r\n\t]+/m, ' '
      str.gsub! %r{ *([;\{\},:]) *}, '\1'
      str
    end

    def js(str, options={})
      str
    end
  end

  Compressor.register :css, :simple, SimpleEngine
  Compressor.register :js,  :simple, SimpleEngine
end
