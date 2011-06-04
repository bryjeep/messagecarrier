require 'sequel'
require 'sqlite3'
require 'sinatra/sequel'

set :database, 'sqlite://messagecarrier.db'

migration "create the messages table" do
  database.create_table :messages do
    primary_key	:messageid
    String		:destination 
    int			:hopcount
    text		:messagebody
    int			:messagetype
    String		:sourceid
    int			:status
    text		:sendername
	String		:location
    timestamp	:timestamp
  end
end
