module Sinatra::AssetPack
  class UglifyEngine < Engine
    def js(str, options={})
      require 'uglifier'
      Uglifier.compile str, options
    rescue => e
      nil
    end
  end

  Compressor.register :js, :uglify, UglifyEngine
end
