#shotgun ./app.rb -p 3000

#dependencies
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'mongo'
require 'uri'

# connect to heroku mongo db 
def connect_to_db
  return @db_connection if @db_connection
  db = URI.parse(ENV['MONGOHQ_URL'])
  db_name = db.path.gsub(/^\//, '')
  @db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
  @db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
  @db_connection
end

# all responses are JSON
before '*' do
  content_type :json
end



get '/seed' do
  @db = connect_to_db
  @coll = @db['articles']
  @coll.remove

  3.times do |i|
    @coll.insert({'a' => i+1})
  end

  { :count => 3, :message => "You successfully seeded the database." }.to_json
end

get '/retrieve' do
  @db = connect_to_db
  @coll = @db['articles']
  articles = @coll.find.toArray()
  
  articles.to_json
end


#errors
not_found do
  { :error => '404', :details => + env['sinatra.error'] }.to_json
end
error do
  { :error => '500', :details => + env['sinatra.error'] }.to_json
end
