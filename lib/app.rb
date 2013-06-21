require File.join(File.dirname(__FILE__), './sync')
require File.join(File.dirname(__FILE__), './mongo')


#
#  Routes
#  
before '*' do
   content_type :json 
   MongoDB.connect()
end

#get ('/erase'){ erase_database }
get ('/batch'){ batch_load }
get ('/sync'){ sync_articles }
get ('/retrieve'){ retrieve_articles }
get ('/') {{ 'hello' => 'world' }.to_json}

not_found || error do
  { :error => '404', :details => + env['sinatra.error'] }.to_json
end


#
# Controller
#

def erase_database
  MongoDB.erase()
  { :message => "Database was erased." }.to_json
end

def batch_load
  resp = Net::HTTP.get( URI(params['url']) )
  links = URI.extract( resp )
  new_count = 0
  
  links.each_slice(10) do |batch|
    rss_articles = SyncAPI.loadLinks( batch )
    new_count += MongoDB.insert( rss_articles )
  end
  { :message => "Saved #{new_count} new articles." }.to_json
end

def sync_articles
  rss_articles = SyncAPI.pull()
  new_count = MongoDB.insert( rss_articles )
  { :message => "Saved #{new_count} new articles." }.to_json
end

def retrieve_articles
  articles = MongoDB.retrieve()
  articles.to_json
end

