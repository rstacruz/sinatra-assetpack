module Sinatra
  module AssetPack
    VERSION = "0.3.1"

    # @deprecated Please use AssetPack::VERSION instead
    def self.version
      VERSION
    end
  end
end
