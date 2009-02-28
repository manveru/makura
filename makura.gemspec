Gem::Specification.new do |s|
  s.name = "makura"
  s.version = "2009.03.01"

  s.summary = "Ruby wrapper around the CouchDB REST API."
  s.description = "Ruby wrapper around the CouchDB REST API."
  s.platform = "ruby"
  s.has_rdoc = true
  s.author = "Michael 'manveru' Fellinger"
  s.email = "m.fellinger@gmail.com"
  s.homepage = "http://github.com/manveru/makura"
  s.executables = ['makura']
  s.bindir = "bin"
  s.require_path = "lib"

  s.add_dependency('rest-client', '>= 0.8.1')
  s.add_dependency('json', '>= 1.1.3')

  s.files = [
    "COPYING",
    "README.md",
    "bin/makura",
    "example/blog.rb",
    "example/couch/map/author_all.js",
    "example/couch/map/author_posts.js",
    "example/couch/map/post_all.js",
    "example/couch/map/post_comments.js",
    "example/couch/reduce/sum_length.js",
    "lib/makura.rb",
    "lib/makura/database.rb",
    "lib/makura/design.rb",
    "lib/makura/error.rb",
    "lib/makura/http_methods.rb",
    "lib/makura/layout.rb",
    "lib/makura/model.rb",
    "lib/makura/plugin/localize.rb",
    "lib/makura/plugin/pager.rb",
    "lib/makura/server.rb",
    "lib/makura/uuid_cache.rb",
    "makura.gemspec"
  ]
end
