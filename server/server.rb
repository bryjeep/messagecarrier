#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?
require './database'

require 'twiliolib'
require 'yajl'

API_VERSION = '2010-04-01'
ACCOUNT_SID = 'AC811c26b1ded5a7246241880f9ec98334'
ACCOUNT_TOKEN = 'cef36b0b4a8d4eb7429178443bb3a6d0'
CALLER_ID = '+14043850750';
account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

get "/" do
  t = {
    'From' => CALLER_ID,
    'To' => "404-909-1495",			
    'Body' => "Hello Me..."
  }
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
             'POST',
             t)
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]
  
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
      if database[:messages].where(:messageid => msg['messageid']).first
        statuses[msg['messageid']] = :existing
      else
        if database[:messages].insert(msg)
          statuses[msg['messageid']] = :accepted
        else
          statuses[msg['messageid']] = :error
        end
      end
    rescue Exception => e
      statuses[msg['messageid']] = :error
    end
  end
  Yajl::Encoder.encode(statuses)

end

helpers do

end
