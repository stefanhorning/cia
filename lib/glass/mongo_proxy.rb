require'mongo'

module Glass
  class MongoProxy < Glass::Base
    
    def db
      connection[@config.db]
    end

    def collection
      db[@config.collection]
    end

    def roles
      config.roles
    end

    def global_key(key)
      collection.find_one("host" => {"$exists" => false}, "role" => {"$exists" => false}, key => {"$exists" => true})
    end

    def role_key(role, key)
      collection.find_one("host" => {"$exists" => false}, "role" =>  role, key => {"$exists" => true})
    end

    def host_key(host, key)
      collection.find_one("host" => host, "role" => {"$exists" => false}, key => {"$exists" => true})
    end

    
    def connect!
      @connection = Mongo::MongoClient.send(:new, config.connection[:host], config.connection[:port])
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

    class Manager

      attr_accessor :mongo_config
 
      def initialize(mongo_config)
        self.mongo_config = mongo_config
      end

      def set_global_key(key, value)
        obj = mongo_config.global_key(key)
        save_or_create_object(obj, key, value)   
      end

      def set_role_key(role, key, value)
        obj = mongo_config.role_key(role, key)
        save_or_create_object(obj, key, value, {"role" =>role}) 
      end

      def set_host_key(host, key, value)
        obj = mongo_config.host_key(host, key)
        save_or_create_object(obj, key, value, {"host" =>host}) 
      end

      private

      def save_or_create_object(obj, key, value, opts={})
        if obj.nil?
          obj = opts
        end
        obj[key] = value
        mongo_config.collection.save(obj)
      end

    end
  end
end
