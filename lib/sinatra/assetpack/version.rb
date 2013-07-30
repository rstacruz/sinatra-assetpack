module Sinatra
  module AssetPack
    VERSION = "0.3.0"

    # @deprecated Please use AssetPack::VERSION instead
    def self.version
      VERSION
    end
  end
end
