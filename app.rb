#shotgun ./app.rb -p 3000

#dependencies
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'

# all responses are JSON
before '*' do
  content_type :json
end


get '/' do

end


#errors
not_found do
  { :error => '404', :details => + env['sinatra.error'] }.to_json
end
error do
  { :error => '500', :details => + env['sinatra.error'] }.to_json
end
