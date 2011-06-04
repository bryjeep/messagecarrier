require 'sequel'
require 'sqlite3'
require 'sinatra/sequel'

set :database, 'sqlite://messagecarrier.db'

migration "create the messages table" do
  database.create_table :messages do
    primary_key :id
    text        :sender
    text        :recipient
    String      :recipient_type
    timestamp   :sent_at
  end
end
