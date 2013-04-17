module Glass
  class Base
    attr_accessor :connection_hash

    def initalize(opts={})
      self.connection_hash = connection_hash
    end


    def config
      @config ||= Glass::Config.new
    end

    def fetch(hostname, value)
      raise "Arrrgghh, implement this now or forever be doomed, Arrrrgh!!!"
    end

  end
end
