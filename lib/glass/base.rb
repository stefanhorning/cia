module Glass
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
      obj = host_key(config.host, key)
      return obj[key] if obj
      
      #role specific
      roles.each do |role|
        obj = role_key(role, key)
        return obj[key] if obj
      end

      #global
      obj = global_key(key)
      return obj[key]  if obj

      close

    end


  end
end
