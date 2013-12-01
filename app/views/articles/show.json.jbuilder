json.extract! @article, :title, :content, :author, :created_at, :updated_at
json.comments @article.comments

