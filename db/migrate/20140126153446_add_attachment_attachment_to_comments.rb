class AddAttachmentAttachmentToComments < ActiveRecord::Migration
  def self.up
    change_table :comments do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :comments, :attachment
  end
end
