require 'makura'

# Setting up everything

# Makura::Model.server = 'http://localhost:5984'
Makura::Model.database = 'mydb'

class Post
  include Makura::Model

  properties :title, :text, :tags
  belongs_to :author

  layout :all

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
