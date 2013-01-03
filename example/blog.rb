require '../lib/makura'

# Setting up everything

Makura::Model.server = 'http://administrator:smokey@localhost:5984'
Makura::Model.database = 'makura-test'

# Remove all the data we have in the database, start from scratch
Makura::Model.database.destroy!
Makura::Model.database.create

class Post
  include Makura::Model

  properties :title, :text, :tags
  belongs_to :author

  layout :all
  filter :created_by
  filter :shorter_than

  save # submit design docs to CouchDB
end

class Author
  include Makura::Model

  property :name

  layout :all
  layout :posts, :reduce => :sum_length #lists posts for this author
  list :skip_if_value_greater_than #allows filtering of only items great than

  save
end

class Comment
  include Makura::Model
  property :text
end

# And here it goes.

author = Author.new('name' => 'Michael Fellinger')
author.save


post = Post.new(
  :title => 'Hello, World!',
  :text => 'This is my first post',
  :author => author)
post.save

puts "All posts with associated author\n\n"
Post.view(:all).each do |post|
  p post
  p post.author
end

puts "Author posts reduced by sum of length\n\n"
Author.view(:posts).each do |res|
  p res
end

t = Makura::Model.server.database('makura-test-replica')
res = Makura::Model.server.replicate({:source=>'makura-test',:target=>'makura-test-replica',:continuous=>true})
puts res

# Test the list using
# curl http://administrator:smokey@localhost:5984/makura-test/_design/Author/_list/skip_if_value_greater_than/posts?val=1