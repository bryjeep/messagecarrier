require 'sequel'
require 'sqlite3'
require 'sinatra/sequel'

set :database, 'sqlite://messagecarrier.db'

migration "create the messages table" do
  database.create_table :messages do
    String	:messageid, :primary_key => true
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
