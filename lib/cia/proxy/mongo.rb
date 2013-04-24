require'mongo'

module Cia
  module Proxy
    class Mongo < Base
      
      def db
        connection[config.db]
      end
      
      def global_obj(key)
        db["global"].find_one("_id" => key)
      end

      def role_obj(role)
        db["roles"].find_one("_id" => role)
      end

      def host_obj(host)
        db["hosts"].find_one("_id" => host)
      end

      def global_value(key)
        process global_obj(key)
      end

      def role_value(role, key)
        process role_obj(role), key
      end

      def host_value(host, key)
        process host_obj(host), key
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
        val = symbolize_keys(val.to_hash) if val.is_a?(Hash)
        val
      end

     
      def symbolize_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
          result[new_key] = new_value
          result
        }
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
          obj = proxy.role_obj(role)
          save_or_create_object(object: obj, collection: "roles", id: role, data: {key => value}) 
        end

        def set_host_value(host, key, value)
          obj = proxy.host_obj(host)
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
