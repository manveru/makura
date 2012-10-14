require '../lib/makura'

# Setting up everything

Makura::Model.server = 'http://Administrator:smokey@localhost:5984'
Makura::Model.database = 'mydb'

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

  layout :posts, :reduce => :sum_length
  layout :all  
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

Post.view(:all).each do |post|
  p post
  p post.author
end
