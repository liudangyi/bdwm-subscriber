require "sinatra/activerecord/rake"
require "./application"

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

desc ""
task :update do
  require "./lib/update"
end
