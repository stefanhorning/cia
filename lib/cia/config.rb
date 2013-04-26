require 'facter'
require 'forwardable'

module Cia
  class Config
    extend Forwardable
   
    PATHS = ['config/cia.yaml']

    attr_accessor :path, :data, :proxy, :_env

    def initialize(opts={})
      self.proxy = opts[:proxy]
      self.proxy = Cia::Proxy::Base.from_sym(self.proxy) if self.proxy.is_a?(Symbol)
      self.proxy.config = self if self.proxy
      self.path = opts[:path]
      self._env = opts[:env]
      load!
    end

    def load!

      if path
        self.data = from_yaml(path) 
      else
        PATHS.each do |path|
          self.data = from_yaml(path) if File.exists?(path)
        end
      end
#puts self.data
      if path
        raise "cannot find config at #{path}" unless self.data
      else
        raise "cannot find config in any of the locations #{PATHS.join(", ")}" unless self.data
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

    def env
      @env ||= lambda do |config|
                 e = (config._env || ENV['RACK_ENV'] || ENV['RAILS_ENV'])
                 e ? e.to_sym : nil        
               end.call(self)
    end

    def_delegator :@proxy, :fetch
    def_delegator :@proxy, :fetch!

    private 

    def from_yaml(path)
      raise "no environment found" unless env
      _data = YAML.load_file(path)[env]
      raise "no config data in file #{path} for environment #{env}" unless _data
      _data
    end


  end
end
