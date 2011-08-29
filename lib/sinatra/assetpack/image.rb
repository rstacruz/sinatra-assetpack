module Sinatra
  module AssetPack
    class Image
      def initialize(file)
        @file = file
      end

      def dimensions
        return @dimensions  unless @dimensions.nil?

         _, _, dim = `identify "#{@file}"`.split(' ')
         w, h = dim.split('x')

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
