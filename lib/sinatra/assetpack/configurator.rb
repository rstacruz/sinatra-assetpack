module Sinatra
  module AssetPack
    module Configurator
      def self.included(klass)
        klass.extend ClassMethods
      end

      module ClassMethods
        def attrib(name)
          define_method(:"#{name}") { |*a|
            value = a.first
            self.instance_variable_set :"@#{name}", value  unless value.nil?
            self.instance_variable_get :"@#{name}"
          }

          alias_method(:"#{name}=", :"#{name}")
        end
      end
    end
  end
end
