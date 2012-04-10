module Sinatra::AssetPack
  class LessEngine < Engine
    def css(str, options={})
      Tilt.new("less", {:style => :compressed}) { str }.render
    rescue LoadError
      nil
    end
  end

  Compressor.register :css, :less, LessEngine
end
