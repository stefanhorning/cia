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

    def configured?
      self.data
    end

    def load!
      self.data = from_yaml(config_path) if config_path
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
      @env ||= (self._env || ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development').to_sym
    end

    def_delegator :@proxy, :fetch
    def_delegator :@proxy, :fetch!

    private 

    def config_path
      if path
        path if File.exists?(path)
      else
        PATHS.detect do |path|
          File.exists?(path)
        end
      end
    end

    def from_yaml(path)
      YAML.load_file(path)[env]
    end


  end
end
