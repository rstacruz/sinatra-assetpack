require 'rack'
require 'sinatra/base'
require 'sinatra/assetpack'

# ### Rack::AssetPack
# Rack middleware version.
#
module Rack
  class AssetPack < Sinatra::Base
    Error = Class.new(StandardError)

    disable :show_exceptions
    enable  :raise_errors

    def initialize(*a, &block)
      @deferred = Array.new

      # Process the given block.
      super *a, &block

      # Ensure that the root dir is set via `a.root '...'`.
      raise Error, "Please set 'root'."  unless self.class.root

      # Run the deferred calls.
      self.class.register Sinatra::AssetPack
      assets do |a|
        @deferred.each { |(meth, args, blk)| a.send meth, *args, &blk }
      end
    end

    # ### root [method]
    # Sets the root path.
    def root(path)
      self.class.set :root, path
    end

    # ### assets [method]
    # Proxy for the assets block. This works exactly like `#assets`
    # when AssetPack is used as a Sinatra plugin.
    def assets(*a, &blk)
      self.class.assets *a, &blk
    end

    # ### asset_block_methods [private method]
    # Returns the methods available for {Options} that can be used directly
    # in `Rack::AssetPack`.
    def self.asset_block_methods
      Sinatra::AssetPack::Options.instance_methods -
      Sinatra::AssetPack::Options.superclass.instance_methods
    end

    def call(*a, &blk)
      status, headers, content = super(*a, &blk)

      # Mangle HTML tags.
      if headers['Content-Type'] &&
        headers['Content-Type'].include?('text/html')
        preproc_tags!  content
      end

      [status, headers, content]
    end

    # Defines methods for each of the methods in the asset block (css, js, etc)
    # that will defer the calls to the real asset block to be made on #initialize.
    asset_block_methods.each do |meth|
      send(:define_method, meth) { |*a, &blk|
        @deferred << [ meth, a, blk ]
      }
    end

  private
    # ### get_attr(tag, attr) [private method]
    # Returns the value of the attribute `attr` from the HTML tag `tag`.
    def get_attr(tag, attr)
      attr_eq = /#{attr}\s*=\s*/i
      tag.scan(/#{attr_eq}'(.*?)'|#{attr_eq}"(.*?)"|#{attr_eq}([^s]*?)/i).flatten.compact.first
    end

    def preproc_tags!(content)
      content.each do |chunk|
        # CSS
        chunk.gsub!(%r{(<link [^>]+?>)}m) { |str|
          href = get_attr(str, 'href')
          pack = assets.package_for(href)
          pack ? pack.to_html : str
        }

        # JavaScript
        chunk.gsub!(%r{(<script [^>]+?>(\s*</script>)?)}m) { |str|
          href = get_attr(str, 'src')
          pack = assets.package_for(href)
          pack ? pack.to_html : str
        }
      end
    end

  end
end
