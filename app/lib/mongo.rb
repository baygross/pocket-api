module MongoDB

  # connects to the mongo database
  def self.connect( db )
    return @db if @db
    @db = Mongo::Connection.new(db['host'], db['port']).db( db['name'] )
    @db.authenticate(db['user'], db['password']) unless db['user'].nil?
    @db
  end

  # inserts an article or array of articles into the database
  def self.insert( articles )
    articles = [articles] if !articles.kind_of?(Array)
    new_count = 0
    
    articles.each do |a|
      next if @db['articles'].find_one(a)
      @db['articles'].insert( a ) 
      new_count += 1
    end
    
    return new_count 
  end

  # retrieves all article documents from the database
  def self.retrieve( )
    @db['articles'].find().to_a.map{|a| a.delete('_id'); a}
  end

  # erases the article collection
  def self.erase( )
    @db['articles'].remove
  end

  # given an array of urls, filters
  #  to only new urls not already in database
  def self.filterUnique( urls )
    existing = @db['articles'].find({ 'url' => {'$in' =>  urls} }, :fields => ['url']).to_a
    return urls - existing.map{|d| d['url']}
  end

end  