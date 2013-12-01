class Article < ActiveRecord::Base
  has_many :comments

  validates :title, presence: true
  validates :content, presence: true
end
