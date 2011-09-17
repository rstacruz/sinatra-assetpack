module Sinatra::AssetPack
  class SqwishEngine < Engine
    def css(str, options={})
      cmd = "#{sqwish_bin} %f "
      cmd += "--strict"  if options[:strict]

      _, input = sys :css, str, cmd
      output   = input.gsub(/\.css/, '.min.css')

      File.read(output)
    rescue => e
      nil
    end

    def sqwish_bin
      ENV['SQWISH_PATH'] || "sqwish"
    end
  end

  Compressor.register :css, :sqwish, SqwishEngine
end
