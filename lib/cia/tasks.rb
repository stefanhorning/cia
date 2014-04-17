require 'rake'
require 'cia'
require 'json'
require 'yaml'


namespace :cia do
  namespace :mongo do

    desc 'sets up a default cia config file and adds the system global value to cia'
    task :setup, [:system] do |t, args|
      Rake::Task["cia:mongo:config"].invoke
      Rake::Task["cia:mongo:add_development_system"].invoke args[:system]
    end

    desc 'creates a default development config file configured for a local mongo database'
    task :config do |t, args|
      if File.exists?(CONFIG_PATH)
        puts "a config/cia.yaml already exists, overwrite ? [Y] for yes"
        write = (STDIN.gets.chomp.strip == 'Y')
      else
        write = true
      end
      File.open(CONFIG_PATH, 'w') { |file| file.write(YAML.dump(DEV_CONFIG)) } if write
    end

    desc 'adds a localhost cia configuration for the named system'
    task :add_development_system, [:system] do |t, args|
      config = Cia::Config.new(:proxy => :mongo)
      config.proxy.manager.set_global_value(args[:system], DEV_VALUE)
    end

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

