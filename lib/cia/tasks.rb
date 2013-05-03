require 'rake'
require 'cia'
require 'json'

namespace :cia do
  namespace :mongo do

    task :set_global_value, [:key, :value] do |t, args|
      config = Cia::Config.new(:proxy => :mongo)
      value = (args[:value] =~ /^\[|^{/ ? JSON.parse(args[:value]) : args[:value]) 
      config.proxy.manager.set_global_value(args[:key], value)
    end

    task :dump do
      config = Cia::Config.new(:proxy => :mongo)
      system("mongodump --host #{config.connection[:host]} --db #{config.db} --out dump_#{config.db}")
    end

  end
end

