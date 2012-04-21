module Sinatra
  module AssetPack
    # The base class for all CSS/JS compression engines.
    #
    # An engine simply has to support #js and #css.
    # Like `def js(string, options={})`.
    #
    class Engine
      # Helper for system files.
      # Usage: sys('css', string, "sqwish %f")
      # Returns stdout.
      def sys(type, str, cmd)
        t = Tempfile.new ['', ".#{type}"]
        t.write(str)
        t.close

        output = `#{cmd.gsub('%f', t.path)}`
        FileUtils.rm t

        [output, t.path]
      end
    end
  end
end
