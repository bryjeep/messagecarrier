#!/usr/bin/ruby

require 'sinatra'
require 'sinatra/reloader' if development?
require './database'

require 'builder'
require 'twiliolib'
require 'yajl'
require 'net/smtp'
require 'twitter'

API_VERSION = '2010-04-01'
ACCOUNT_SID = 'AC811c26b1ded5a7246241880f9ec98334'
ACCOUNT_TOKEN = 'cef36b0b4a8d4eb7429178443bb3a6d0'
CALLER_ID = '+14155992671' #'+14043850750'

Twitter.configure do |config|
  config.consumer_key = 'S11BNOKK1uwsTFFmfTYA'
  config.consumer_secret = 'z29Ttv1OmBH0Qvo0mI6C3wLn4787lldjLMWGKdiDQ'
  config.oauth_token = '310774926-mr98j32Iq9TxHsPttnNlQsM17B0svm3oSbDcRYQo'
  config.oauth_token_secret = 'MIlROjzxOTulvZszM3WP9l05aE43GnoIAigRSupmhLA'
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
          statuses[msg['messageid']] = :error
        end
      end
      
	  from = 'messagecarrier@lavabit.com'
	  to = msg['destination']
	  smtp_host   = 'lavabit.com'
	  smtp_port   = 25
	  smtp_domain = 'lavabit.com'
	  smtp_user   = 'messagecarrier'
	  smtp_pwd    = 'rh0kATL'
	  
	  subject = '[MessageCarrier] Test Email'
	  emailbody = msg['messagebody']
	  time = Time.now
	  emaildate = time.strftime("%a, %d %b %Y %H:%M:%S -0400")

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
      
    rescue Exception => e
      statuses[msg['messageid']] = :error
    end
  end
  Yajl::Encoder.encode(statuses)

end

helpers do
  def format_text(msg)
    "Emergency msg from #{msg['sendername']}: #{msg['messagebody']}"
  end

  def send_sms(msg)
    t = {
      'From' => CALLER_ID,
      'To' => msg['destination'],			
      'Body' => format_text(msg)
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
    true # TODO: handle errors
  end

  def send_email(msg)
    from = 'messagecarrier@lavabit.com'
    to = msg['destination']
    smtp_host   = 'lavabit.com'
    smtp_port   = 25
    smtp_domain = 'lavabit.com'
    smtp_user   = 'messagecarrier'
    smtp_pwd    = 'rh0kATL'
    
    subject = "[MessageCarrier] Emergency Message from #{msg['sendername']}"
    time = Time.now
    emaildate = time.strftime("%a, %d %b %Y %H:%M:%S -0400")
    
    #Compose the message for the email
    emailmsg = <<END_OF_MESSAGE
Date: #{emaildate}
From: #{from}
To: #{to}
Subject: #{subject}

You have received a message from #{msg['sendername']} from an
area experiencing a communications emergency:

  #{msg['messagebody']}

Please don't reply to this email, it will not be delivered.
END_OF_MESSAGE

    Net::SMTP.start(smtp_host, smtp_port, smtp_domain, smtp_user, smtp_pwd, :plain) do |smtp|
      smtp.send_message emailmsg, from, to
    end
  end

  def send_twitter(msg)
    # Twitter.update("Now tweeting with location!", {"status" => "Now with Geo Location Support!", "lat" => "33.778463", "long" => "-84.398881", "display_coordinates" => "true"})
    Twitter.update(format_text(msg))
  end

end
