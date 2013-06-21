#
#  Routes
#  
#get ('/erase'){ erase_database }
get ('/batch'){ batch_load }
get ('/sync'){ sync_articles }
get ('/retrieve'){ retrieve_articles }
get ('/') {{ 'hello' => 'world' }.to_json}

not_found {{ :error => '404', :details => env['sinatra.error'] }.to_json}
error {{ :error => '500', :details => env['sinatra.error'] }.to_json}

#
# Controller
#

before '*' do
   content_type :json 
   App.init()
end

def erase_database
  App.erase()
  { :message => "Database was erased." }.to_json
end

def batch_load
  App.batchLoad( params['url'] )
  { :message => "Batching job in background." }.to_json
end

def sync_articles
  new_count = App.sync()
  { :message => "Saved #{new_count} new articles." }.to_json
end

def retrieve_articles
  App.retrieve()
end

