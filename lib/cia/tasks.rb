require 'rake'
require 'cia'
require 'json'

namespace :cia do
  namespace :mongo do

    desc 'saves the global value to the config mongodb specified in the RAILS_ENV environment'
    task :set_global_value, [:key, :value] do |t, args|
      config = Cia::Config.new(:proxy => :mongo)
      value = (args[:value] =~ /^\[|^{/ ? JSON.parse(args[:value]) : args[:value])
      puts "saving #{args[:key]}=#{value} to #{config.connection[:host]}##{config.db}" 
      config.proxy.manager.set_global_value(args[:key], value)
      Rake::Task["cia:mongo:dump"].invoke
      Rake::Task["cia:mongo:scp"].invoke
    end

    desc 'dumps the config mongodb specified in the rails environment'
    task :dump do
      config = Cia::Config.new(:proxy => :mongo)
      puts "dumping config database"
      system("mongodump --host #{config.connection[:host]} --db #{config.db} --out dump_#{config.db}")
    end

    desc 'scp the dump across to te server it came from'
    task :scp do
      config = Cia::Config.new(:proxy => :mongo)
      puts "scp mongodump dump_#{config.db} to deploy@#{config.connection[:host]}#"
      system("scp -r dump_#{config.db} deploy@#{config.connection[:host]}:")
    end

  end
end

