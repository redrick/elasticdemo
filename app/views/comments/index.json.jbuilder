json.array!(@comments) do |comment|
  json.extract! comment, :author, :message, :article_id
  json.url comment_url(comment, format: :json)
end
