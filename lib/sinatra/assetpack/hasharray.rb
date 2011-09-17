module Sinatra
  module AssetPack
    # Class: HashArray
    # A stopgap solution to Ruby 1.8's lack of ordered hashes.
    #
    # A HashArray, for all intents and purposes, acts like an array. However, the
    # common stuff are overloaded to work with hashes.
    #
    # ## Basic usage
    #
    # #### Creating
    # You can create a HashArray by passing it an array.
    #
    #     dict = HashArray.new([
    #       { :good_morning => "Bonjour" },
    #       { :goodbye      => "Au revoir" },
    #       { :good_evening => "Bon nuit" }
    #     ])
    #
    # #### Converting
    # You may also use it like so:
    #
    #     letters = [ { :a => "Aye"}, { :b => "Bee" } ].to_hash_array
    #
    # #### Iterating
    # Now you can use the typical enumerator functions:
    #
    #     dict.each do |(key, value)|
    #       puts "#{key} is #{value}"
    #     end
    #
    #     #=> :good_morning is "Bonjour"
    #     #   :goodbye is "Au revoir"
    #     #   :good_evening is "Bon nuit"
    #
    class HashArray < Array
      def self.[](*arr)
        new arr.each_slice(2).map { |(k, v)| Hash[k, v] }
      end

      # Works like Hash#values.
      def values
        inject([]) { |a, (k, v)| a << v; a }
      end

      # Returns everything as a hash.
      def to_hash
        inject({}) { |hash, (k, v)| hash[k] = v; hash }
      end

      def keys
        inject([]) { |a, (k, v)| a << k; a }
      end

      [:each, :map, :map!, :reject, :reject!, :select, :select!].each do |meth|
        send(:define_method, meth) { |*a, &block|
          if block.respond_to?(:call)
            super(*a) { |hash| block.call *hash.to_a }
          else
            super(*a)
          end
        }
      end
    end
  end
end
