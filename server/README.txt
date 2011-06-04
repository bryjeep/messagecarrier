# Message Carrier Server
## GETTING SETUP

* Install RVM
  http://rvm.beginrescueend.com/
* rvm install ruby-1.9.2
* rvm use 1.9.2
* rvm gemset create messagecarrier
* gem install bundler
* bundle install

### RUNNING DEV SERVER

* bundle exec rackup

PUSHING LIVE (not yet)

##### Message JSON API (Name : Value)
"destination" : String #Phone number, Twitter Handle, or Email Address
"hopcount" : Int #Number of hops between phones from sender to server
"messagebody" : String #The message, limited 140 characters by sender
"messageid" : Hex String #Random message id string
"messagetype" : Int #0 = sms, 1 = email, 2 = twitter
"sourceid" : String #sender UUID
"status" : Int #404 = failure; 200 = successfully sent and received
"sendername" : String #User Entered name of sender
"location" : String #GPS coordinates, format TBD
"timestamp" : String #unix time stamp

