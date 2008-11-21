require 'sofa'

# Setting up everything

# Sofa::Model.server = 'http://localhost:5984'
Sofa::Model.database = 'mydb'

class Post
  include Sofa::Model

  properties :title, :text, :tags
  belongs_to :author

  layout :all

  validates(:title){ presence and length :within => (3..100) }
  validates(:text){ presence }

  save # submit design docs to CouchDB
end

class Author
  include Sofa::Model

  property :name

  layout :posts, :reduce => :sum_length
  layout :all

  save
end

class Comment
  include Sofa::Model

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
