#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?
require './database'

require 'builder'
require 'twiliolib'
require 'yajl'

require 'net/smtp'

API_VERSION = '2010-04-01'
ACCOUNT_SID = 'AC811c26b1ded5a7246241880f9ec98334'
ACCOUNT_TOKEN = 'cef36b0b4a8d4eb7429178443bb3a6d0'
CALLER_ID = '+14155992671' #'+14043850750'

get "/" do
=begin
  t = {
    'From' => CALLER_ID,
    'To' => "4043850750",			
    'Body' => "Hello Me..."
  }
  begin
    account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)
    resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
             'POST',
             t)
  ensure
    puts "Twilio Response: " + resp.body
  end
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]
=end

=begin
from = 'messagecarrier@lavabit.com'
to = 'brad.beglin@gatech.edu'
smtp_host   = 'lavabit.com'
smtp_port   = 25
smtp_domain = 'lavabit.com'
smtp_user   = 'messagecarrier'
smtp_pwd    = 'rh0kATL'

subject = '[MessageCarrier] Test Email'
emailbody = "Hello World.\n"
time = Time.now
emaildate = time.strftime("%a, %d %b %Y %H:%M:%S -0400")

#Compose the message for the email
emailmsg = <<END_OF_MESSAGE
Date: #{emaildate}
From: #{from}
To: #{to}
Subject: #{subject}
  
#{emailbody}
END_OF_MESSAGE

Net::SMTP.start(smtp_host, smtp_port, smtp_domain, smtp_user, smtp_pwd, :plain) do |smtp|
  smtp.send_message emailmsg, from, to
end
=end  
  
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
