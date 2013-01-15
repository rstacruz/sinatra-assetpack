module Sinatra
  module AssetPack
    # An image.
    #
    # == Common usage
    #
    #     i = Image['/app/images/background.png']    # Local file path
    #
    #     i.dimensions     # Tuple for [ width, height ]
    #     i.width
    #     i.height
    #
    #     i.dimensions?    # True if dimensions are available
    #                      # (e.g., if ImageMagick is installed and working)
    #
    class Image
      # Looks up an image.
      # This makes each image only have one associated instance forever.
      def self.[](fname)
        fname = File.expand_path(fname) || fname

        @cache        ||= Hash.new
        @cache[fname] ||= new fname
      end

      def initialize(file)
        @file = file
      end

      def dimensions
        return @dimensions  unless @dimensions.nil?

        dim = /(\d+) x (\d+)/.match(`file "#{@file}"`)
        w, h = dim[1,2]

         if w.to_i != 0 && h.to_i != 0
           @dimensions = [w.to_i, h.to_i]
         else
           @dimensions = false
         end

      rescue => e
        @dimensions = false
      end

      def dimensions?
        !! dimensions
      end

      def width
        dimensions? && dimensions[0]
      end

      def height
        dimensions? && dimensions[1]
      end
    end
  end
end
