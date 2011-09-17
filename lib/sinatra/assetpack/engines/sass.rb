module Sinatra::AssetPack
  class SassEngine < Engine
    def css(str, options={})
      Tilt.new("scss", {:style => :compressed}) { str }.render
    rescue LoadError
      nil
    end
  end

  Compressor.register :css, :sass, SassEngine
end
