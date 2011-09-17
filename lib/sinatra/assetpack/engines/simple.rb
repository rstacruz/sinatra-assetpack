module Sinatra::AssetPack
  class SimpleEngine < Engine
    def css(str, options={})
      str.gsub! /[ \r\n\t]+/m, ' '
      str.gsub! %r{ *([;\{\},:]) *}, '\1'
      str
    end
  end

  Compressor.register :css, :simple, SimpleEngine
end
