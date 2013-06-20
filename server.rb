#shotgun ./app.rb -p 3000

#dependencies
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'json'
require 'mongo'
require 'uri'

#include application
require File.join(File.dirname(__FILE__), '/lib/app')