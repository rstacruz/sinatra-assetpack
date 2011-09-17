module Sinatra::AssetPack
  class YuiEngine < Engine
    def initialize
      require 'yui/compressor'
    end

    def js(str, options={})
      YUI::JavaScriptCompressor.new(options).compress(str)
    rescue LoadError
      nil
    end

    def css(str, options={})
      YUI::CssCompressor.new.compress(str)
    rescue Errno::ENOENT
      nil
    end
  end

  Compressor.register :js,  :yui, YuiEngine
  Compressor.register :css, :yui, YuiEngine
end
