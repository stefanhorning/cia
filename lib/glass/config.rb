require 'facter'
require 'forwardable'

module Glass
  class Config
    extend Forwardable
   
    PATHS = ['config/glass.yaml']

    attr_accessor :path, :data, :proxy

    def initialize(opts={})
      self.proxy = opts[:proxy]
      self.proxy = Glass::Proxy::Base.get(self.proxy) if self.proxy.is_a?(Symbol)
      self.proxy.config = self if self.proxy
      self.path = opts[:path]
      load!
    end

    def load!

      if path
        self.data = YAML.load_file(path)
      else
        PATHS.each do |path|
          self.data = YAML.load_file path if File.exists?(path)
        end
      end

      if path
        raise "cannot find config at #{path}" unless data
      else
        raise "cannot find config in any of the locations #{PATHS.join(", ")}" unless data
      end
      
    end

    def method_missing(mefod, *args)
      if data && data.has_key?(mefod) && args.empty?
        return data[mefod]
      end
      super
    end
    
    def host
      Facter.hostname
    end

    def_delegator :@proxy, :fetch
    def_delegator :@proxy, :fetch!


  end
end
