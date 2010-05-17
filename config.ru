require 'rubygems'
require 'bundler'
Bundler.setup
require 'sinatra'
require 'imageserver'

root_dir = File.dirname(__FILE__)

set :environment, ENV['RACK_ENV'].to_sym
set :root,        root_dir
set :app_file,    File.join(root_dir, 'imageserver.rb')
disable :run

run Sinatra::Application
