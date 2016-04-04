require 'yaml'

namespace :sidekiq do
  task :start do
    yaml = YAML.load(ERB.new(File.read('./config/sidekiq.yml')).result)[Rails.env]
    pidfile = yaml['pidfile']
    logfile = yaml['logfile']
    errlog = yaml['errlog']
    puts "sidekiq process starts now..."
    exec "bundle exec sidekiq -d -L #{logfile} -P #{pidfile}"
  end

  task :stop do
    yaml = YAML.load(ERB.new(File.read('./config/sidekiq.yml')).result)[Rails.env]
    pidfile = yaml['pidfile']
    pid = File.open(pidfile, "r").gets
    system "kill -9 #{pid}"
    system "rm #{pidfile}"
  end

  task :restart do
    Rake::Task["sidekiq:stop"].execute
    Rake::Task["sidekiq:start"].execute
  end
end
