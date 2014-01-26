class Comment < ActiveRecord::Base
  belongs_to :article

  validates :author, presence: true
  validates :message, presence: true

  has_attached_file :attachment

  validates_attachment :attachment, size: { :in => 0..100.kilobytes }

    #######################################
   #       (Elasticsearch + Tire)        #   
  #######################################
  include Tire::Model::Search
  include Tire::Model::Callbacks

  # I am giving the index name according to env
  index_name("#{Rails.env}-comments")

  after_save lambda { self.article.update_index }
  after_destroy lambda { self.article.update_index }

  mapping do
    indexes :id, type: 'integer'
    indexes :author, type: 'string'
    indexes :message, type: 'string'
    indexes :created_at, type: 'date', :include_in_all => false
    indexes :updated_at, type: 'date', :include_in_all => false
    indexes :attachment_file_name, type: 'string'
    indexes :attachment_content_type, type: 'string'
    indexes :attachment_content, type: 'attachment'
  end

  class << self
    
    def delete_search_index
      Tire.index(Comment.index_name).delete
    end

  end

  def to_indexed_json
    {
      author: self.author,
      message: self.message,
      attachment_file_name: self.attachment_file_name,
      attachment_content_type: self.attachment_content_type,
      attachment_content: ( (!!self.attachment.path && File.exists?(self.attachment.path)) ? Base64.encode64(File.read(self.attachment.path)) : '' )
    }.to_json
  end
  
end
