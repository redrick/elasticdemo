class Article < ActiveRecord::Base
  
  has_many :comments

  validates :title, presence: true
  validates :content, presence: true


    #######################################
   #       (Elasticsearch + Tire)        #   
  #######################################
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # I am giving the index name according to env
  index_name("#{Rails.env}-articles")

  mapping _source: {excludes: ['comments']} do
    indexes :id, type: 'integer'
    indexes :author, :type => 'string'
    indexes :title, :type => 'string'
    indexes :content, :type => 'string'
    indexes :comments do
      indexes :author, analyzer: 'snowball'
      indexes :message, analyzer: 'snowball'
    end
  end

  class << self
    
    def delete_search_index
      Tire.index(Article.index_name).delete
    end

  end
  
  def to_indexed_json
    {
      id: self.id,
      author: self.author,
      title: self.title,
      content: self.content,
      comments: comments.map { |c| {
          _id: c.id,
          author: c.author, 
          message: c.message
        }
      }
    }.to_json
  end
end
