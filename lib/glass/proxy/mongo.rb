require'mongo'

module Glass
  module Proxy
    class Mongo < Base
      
      def db
        connection[config.db]
      end

      def roles
        config.roles
      end

      def global_obj(key)
        db["global"].find_one("_id" => key)
      end

      def role_obj(role, key)
        db["roles"].find_one("_id" => role)
      end

      def host_obj(host, key)
        db["hosts"].find_one("_id" => host)
      end

      def global_value(key)
        process global_obj(key)
      end

      def role_value(role, key)
        process role_obj(role, key), key
      end

      def host_value(host, key)
        process host_obj(host, key), key
      end

      def connect!
        @connection = ::Mongo::MongoClient.new(config.connection[:host], config.connection[:port])
      end

      def close
        @connection.close
      end

      def connection
        @connection
      end

      def manager
        @manager ||= Manager.new(self)
      end

      private

      def process(result, identifier="value")
        return nil unless result
        val = result[identifier]
        val = symbolize(val) if val.is_a?(Hash)
        val
      end

      def symbolize(val)
        val.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      end

      class Manager

        attr_accessor :proxy
   
        def initialize(proxy)
          self.proxy = proxy
          self.proxy.connect!
        end

        def set_global_value(key, value)
          obj = proxy.global_obj(key)
          save_or_create_object(object: obj, collection: "global", id: key, data: {"value" => value})   
        end

        def set_role_value(role, key, value)
          obj = proxy.role_obj(role, key)
          save_or_create_object(object: obj, collection: "roles", id: role, data: {key => value}) 
        end

        def set_host_value(host, key, value)
          obj = proxy.host_obj(host, key)
          save_or_create_object(object: obj, collection: "hosts", id: host, data: {key => value}) 
        end

        private

        def save_or_create_object(*args)
          args = args.flatten.first
          obj = args[:object]
          if obj.nil?
            obj = {"_id" => args[:id]}
          end
          obj.merge!(args[:data])
          proxy.db[args[:collection]].save(obj)
        end

      end

    end
  end
end
