#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?

get "/" do
  erb :index
end

helpers do

end
