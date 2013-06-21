require './app/init.rb'
puts 'Pulling down RSS and syncing articles...'
App.init()
App.sync()
puts 'Done!'