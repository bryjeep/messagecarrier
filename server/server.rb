#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?
require './database'

require 'yajl'

get "/" do
  erb :index
end


post "/messages" do
  content_type :json
  statuses = { }
  messages = Yajl::Parser.parse(request.body.read)
  unless messages.is_a?(Array)
    messages = [messages]
  end
  messages.each do |msg|
    begin
      if database[:messages].where(:id => msg['id']).first
        statuses[msg['id']] = :existing
      else
        if database[:messages].insert(msg)
          statuses[msg['id']] = :accepted
        else
          statuses[msg['id']] = :error
        end
      end
    rescue Exception => e
      statuses[msg['id']] = :error
    end
  end
  Yajl::Encoder.encode(statuses)
end

helpers do

end
