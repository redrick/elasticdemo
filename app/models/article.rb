class Article < ActiveRecord::Base
  
  has_many :comments

  validates :title, presence: true
  validates :content, presence: true

  has_attached_file :attachment
  
  validates_attachment :attachment, size: { :in => 0..100.kilobytes }

    #######################################
   #       (Elasticsearch + Tire)        #   
  #######################################
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # I am giving the index name according to env
  index_name("#{Rails.env}-articles")

  mapping _source: {excludes: ['comments']} do
    indexes :id, type: 'integer'
    indexes :author, type: 'string'
    indexes :title, type: 'string'
    indexes :content, type: 'string'
    indexes :comments do
      indexes :author, analyzer: 'snowball'
      indexes :message, analyzer: 'snowball'
      indexes :attachment_file_name, analyzer: 'snowball'
      indexes :attachment_content_type, analyzer: 'snowball'
      indexes :attachment_content, type: 'attachment'
    end
    indexes :attachment_file_name, type: 'string'
    indexes :attachment_content_type, type: 'string'
    indexes :attachment_content, type: 'attachment'
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
          message: c.message,
          attachment_file_name: c.attachment_file_name,
          attachment_content_type: c.attachment_content_type,
          attachment_content: ( (!!c.attachment.path && File.exists?(c.attachment.path)) ? Base64.encode64(File.read(c.attachment.path)) : '' )
        }
      },
      attachment_file_name: self.attachment_file_name,
      attachment_content_type: self.attachment_content_type,
      attachment_content: ( (!!self.attachment.path && File.exists?(self.attachment.path)) ? Base64.encode64(File.read(self.attachment.path)) : '' )
    }.to_json
  end
end
