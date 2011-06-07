#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?
require './database'

require 'builder'
require 'twiliolib'
require 'yajl'
require 'net/smtp'
require 'twitter'

TWILIO_API_V = '2010-04-01'

keys = MessageCarrierSecretKeys.new()

Twitter.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.oauth_token = ''
  config.oauth_token_secret = ''
end


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
      if database[:messages].where(:messageid => msg['messageid']).first
        statuses[msg['messageid']] = :existing
      else
        if database[:messages].insert(msg)
          if msg['messagetype'].to_i == 0
            send_sms(msg)
          elsif msg['messagetype'].to_i == 1
            send_email(msg)
          elsif msg['messagetype'].to_i == 2
            send_twitter(msg)
          else
            # TODO: handle unknown message types
          end
          statuses[msg['messageid']] = :accepted
        else
          puts "DB error"
          statuses[msg['messageid']] = :error
        end
      end
    rescue Exception => e
      puts e.inspect
      statuses[msg['messageid']] = :error
    end
  end
  Yajl::Encoder.encode(statuses)

end

helpers do
  def format_text(msg)
    "Emergency msg: #{msg['messagebody']}"
  end
  
  def send_sms(msg)
    t = {
      'From' => keys.TWILIO_CALLER_ID,
      'To' => msg['destination'],			
      'Body' => format_text(msg)
    }
    begin
      account = Twilio::RestAccount.new(keys.TWILIO_SID, keys.TWILIO_TOKEN)
      resp = account.request("/#{TWILIO_API_V}/Accounts/#{keys.TWILIO_SID}/SMS/Messages",
                             'POST',
                             t)
    ensure
      puts "Twilio Response: " + resp.body
    end
    resp.error! unless resp.kind_of? Net::HTTPSuccess
    puts "code: %s\nbody: %s" % [resp.code, resp.body]
    true # TODO: handle errors
  end

  def send_email(msg)
    from = 'messagecarrier@lavabit.com'
    to = msg['destination']
    smtp_host   = 'lavabit.com'
    smtp_port   = 25
    smtp_domain = 'lavabit.com'
    smtp_user   = ''
    smtp_pwd    = ''
    
    subject = "[MessageCarrier] Emergency Message"
    time = Time.now
    emaildate = time.strftime("%a, %d %b %Y %H:%M:%S -0400")
    
    #Compose the message for the email
    emailmsg = <<END_OF_MESSAGE
Date: #{emaildate}
From: #{from}
To: #{to}
Subject: #{subject}

You have received a message from an
area experiencing a communications emergency:

  #{msg['messagebody']}

Please don't reply to this email, it will not be delivered.
END_OF_MESSAGE

    Net::SMTP.start(smtp_host, smtp_port, smtp_domain, smtp_user, smtp_pwd, :plain) do |smtp|
      smtp.send_message emailmsg, from, to
    end
  end

  def send_twitter(msg)
    latlong = msg['location'].split(',')
    Twitter.update(msg['messagebody'], {"lat" => latlong[0], "long" => latlong[1], "display_coordinates" => "true"})
    #Twitter.update(format_text(msg))
  end

end
