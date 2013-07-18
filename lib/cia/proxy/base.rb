require 'logger'

module Cia
  module Proxy
    class Base

      attr_accessor :config

     def roles
        host_value(config.host, "roles") || []  
      end

      def fetch!(key)
        val = fetch(key)
        raise NoConfigurationError.new("no configuration found for #{key}") unless val
        val
      end

      def fetch(key)

        connect!

        #host specific
        obj = host_value(config.host, key)
        if obj
          #LOG.info("host_key: #{config.host}:#{key} = #{obj}")
          return obj 
        end
  
        #role specific
        roles.each do |role|
          obj = role_value(role, key)
          if obj
            #LOG.info("role_key: #{role}:#{key} = #{obj}")
            return obj 
          end
        end
        
        #global
        obj = global_value(key)
        if obj
          #LOG.info("global_key: #{key} = #{obj}")
          return obj 
        end
 
        close

      end

      def self.from_sym(sym)
        case sym
        when :mongo
          return Cia::Proxy::Mongo.new
        else
          raise "unknown proxy #{sym}"
        end
      end

    end
  end
end
