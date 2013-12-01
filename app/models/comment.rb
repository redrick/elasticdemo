class Comment < ActiveRecord::Base
  belongs_to :article

  validates :author, presence: true
  validates :message, presence: true
end
