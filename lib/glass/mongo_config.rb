require'mongo'

module Glass
  class MongoConfig < Glass::Base
    
    def db
      @config.db
    end

    def collection
      @config.collection
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

    def host_key(key)
      collection.find_one("host" => config.host, "role" => {"$exists" => false}, key => {"$exists" => true})
    end

    def fetch(key)
      #host specific
      obj = host_key(key)
      return obj[key] if obj
      
      #role specific
      roles.each do |role|
        obj = role_key(role, key)
        return obj[key] if obj
      end

      #global
      obj = global_key(key)
      return obj[key]  if obj

    end

    def connect!
      Mongo::MongoClient.new(config.connection_hash)
    end

    def connection
      @connection ||= connect!
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
