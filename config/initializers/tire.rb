Tire.configure do
  if Rails.env == 'production'
    url "http://tbmewfuu:3un3ems9ktjrxksp@cedar-3944652.eu-west-1.bonsai.io"
  end
  logger Rails.root + "log/tire_#{Rails.env}.log"
end

## detecting all created indexes and deleting all at once
indexes = Yajl::Parser.parse(Tire::Configuration.client.get("#{Tire::Configuration.url}/_aliases").body).keys
indexes.each do |index_name|
  Tire.index("#{index_name}").delete
end

##
# I should discourage you from using this block right here,
# but sometimes I just want to do exactly this and not to get runtime error,
# just the message :)
##
begin
  Article.create_elasticsearch_index
  Article.import include: ['comments']

  Comment.create_elasticsearch_index
  Comment.import
rescue
  puts  "#### INFO: ElasticSearch: I got no data to create index from... ####\n"
end
