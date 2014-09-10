require "sinatra/activerecord/rake"
require "./config/application"

desc "Start the server"
task :server do
  Sinatra::Application.run!
end

desc "Start a console to debug"
task :console do
  require "pry"
  pry
end

task :c => :console
task :s => :server

desc "Scrape bdwm.net and send mails"
task :update do
  require "./lib/update"
end

desc "Generate nginx_conf file"
task "setup:nginx" do
  pwd = File.dirname(__FILE__);
  File.write("config/nginx.conf", ERB.new(File.read("config/nginx_conf.erb")).result(binding))
end
