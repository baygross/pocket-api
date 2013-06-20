module MongoDB
  
  
  def self.connect()
    return @db if @db
    db = URI.parse(ENV['MONGOHQ_URL'])
    db_name = db.path.gsub(/^\//, '')
    @db = Mongo::Connection.new(db.host, db.port).db(db_name)
    @db.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
    @db
  end
  
  
  def self.insert( articles )
    articles = [articles] if !articles.kind_of?(Array)
    new_count = 0
    
    articles.each do |a|
      next if @db.articles.find( a )
      @db.articles.insert( a ) 
      new_count += 1
    end
    
    return new_count 
  end
  
  
  def self.retrieve( )
    @db.articles.find().toArray()
  end
  
  
  def self.erase( )
    @db.articles.remove
  end
  
end
  
  