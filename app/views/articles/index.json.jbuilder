json.array!(@articles) do |article|
  json.extract! article, :title, :content, :author
  json.comments article.comments
  json.url article_url(article, format: :json)
end
