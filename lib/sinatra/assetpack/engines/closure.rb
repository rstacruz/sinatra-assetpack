module Sinatra::AssetPack
  class ClosureEngine < Engine
    def js(str, options={})
      require 'net/http'
      require 'uri'

      response = Net::HTTP.post_form(URI.parse('http://closure-compiler.appspot.com/compile'), {
        'js_code' => str,
        'compilation_level' => options[:level] || "ADVANCED_OPTIMIZATIONS",
        'output_format' => 'text',
        'output_info' => 'compiled_code'
      })

      response.body
    end
  end

  Compressor.register :js, :closure, ClosureEngine
end
