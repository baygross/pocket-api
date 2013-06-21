module App
  
  def self.init()
    MongoDB.connect( CONFIG['db'] )
  end
  
  def self.sync()
    links = SyncAPI.grabRSS( CONFIG['pocket_user'] )
    links = MongoDB.filterUnique( links )
    articles = SyncAPI.loadLinks( links, CONFIG['diffbot_token'] )
    MongoDB.insert( articles )
  end
  
  def self.retrieve()
    articles = MongoDB.retrieve()
    articles.to_json
  end
  
  def self.batchLoad( source )
    resp = Net::HTTP.get( URI(source) )
    links = URI.extract( resp )
  
    links = MongoDB.filterUnique( links )
  
    links.each_slice(10) do |batch|
      rss_articles = SyncAPI.loadLinks( batch, CONFIG['diffbot_token'] )
      MongoDB.insert( rss_articles )
    end
  end
  
  def self.erase()
    MongoDB.erase()
  end
  
end