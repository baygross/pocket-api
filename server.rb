# dependencies
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'mongo'
require 'uri'
require 'yaml'

# load configuration environment
CONFIG = YAML.load_file(File.dirname(__FILE__) + '/config.yml')

# swap DB settings for heroku on production
if Sinatra::Base.production?
  db = URI.parse(ENV['MONGOHQ_URL'])
  CONFIG['db'] = {
    'host' => db.host,
    'port' => db.port,
    'name' => db.path.gsub(/^\//, ''),
    'user' => db.user,
    'password' => db.password
  }
end

# then load our app
require File.join(File.dirname(__FILE__), 'lib', 'app')


