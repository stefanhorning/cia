module Glass
  module Proxy
    class Base

      attr_accessor :config

      def fetch!(key)
        val = fetch(key)
        raise NoConfigurationError.new("no configuration found for #{key}") unless val
        val
      end

      def fetch(key)

        connect!

        #host specific
        obj = host_value(config.host, key)
        return obj if obj
        
        #role specific
        roles.each do |role|
          obj = role_value(role, key)
          return obj if obj
        end
        
        #global
        obj = global_value(key)
        return obj if obj

        close

      end

      def self.get(sym)
        case sym
        when :mongo
          return Glass::Proxy::Mongo.new
        else
          raise "unknown proxy #{sym}"
        end
      end

    end
  end
end
