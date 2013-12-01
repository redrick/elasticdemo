class Comment < ActiveRecord::Base
  belongs_to :article

  validates :author, presence: true
  validates :message, presence: true


    #######################################
   #       (Elasticsearch + Tire)        #   
  #######################################
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # I am giving the index name according to env
  index_name("#{Rails.env}-comments")

  mapping do
    indexes :id, type: 'integer'
    indexes :author, type: 'string'
    indexes :message, type: 'string'
    indexes :created_at, type: 'date', :include_in_all => false
    indexes :updated_at, type: 'date', :include_in_all => false
  end

  class << self
    
    def delete_search_index
      Tire.index(Comment.index_name).delete
    end

  end

  def to_indexed_json
    {
      
      }.to_json
  end
  
end
