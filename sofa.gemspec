Gem::Specification.new do |s|
  s.name = "sofa"
  s.version = "2008.12.24"

  s.summary = "Ruby wrapper around the CouchDB REST API."
  s.description = "Ruby wrapper around the CouchDB REST API."
  s.platform = "ruby"
  s.has_rdoc = true
  s.author = "Michael 'manveru' Fellinger"
  s.email = "m.fellinger@gmail.com"
  s.homepage = "http://github.com/manveru/sofa"
  s.executables = ['sofa']
  s.bindir = "bin"
  s.require_path = "lib"

  s.add_dependency('rest-client', '>= 0.8.1')
  s.add_dependency('json', '>= 1.1.3')

  s.files = [
    "COPYING",
    "README.md",
    "bin/sofa",
    "example/blog.rb",
    "example/couch/map/author_all.js",
    "example/couch/map/author_posts.js",
    "example/couch/map/post_all.js",
    "example/couch/map/post_comments.js",
    "example/couch/reduce/sum_length.js",
    "lib/sofa/database.rb",
    "lib/sofa/design.rb",
    "lib/sofa/error.rb",
    "lib/sofa/http_methods.rb",
    "lib/sofa/layout.rb",
    "lib/sofa/model.rb",
    "lib/sofa/plugin/pager.rb",
    "lib/sofa/server.rb",
    "lib/sofa/uuid_cache.rb",
    "lib/sofa.rb",
    "sofa.gemspec"
  ]
end
