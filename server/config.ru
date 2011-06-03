require 'rubygems'
require 'bundler'

Bundler.require(:default)

require "./server"
run Sinatra::Application
