module Sinatra
  module AssetPack
    module Configurator
      def attrib(name)
        define_method(:"#{name}") { |value=nil|
          self.instance_variable_set :"@#{name}", value  unless value.nil?
          self.instance_variable_get :"@#{name}"
        }

        alias_method(:"#{name}=", :"#{name}")
      end
    end
  end
end
