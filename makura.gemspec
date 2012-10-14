# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "makura"
  s.version = "2012.10.14"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael 'manveru' Fellinger"]
  s.date = "2012-10-14"
  s.email = "m.fellinger@gmail.com"
  s.executables = ["makura"]
  s.files = [".gems", ".rvmrc", "AUTHORS", "CHANGELOG", "COPYING", "MANIFEST", "README.md", "Rakefile", "bin/makura", "doc/AUTHORS", "doc/CHANGELOG", "example/blog.rb", "example/couch/filter/post/created_by.js", "example/couch/filter/post/shorter_than.js", "example/couch/map/author/all.js", "example/couch/map/author/posts.js", "example/couch/map/post/all.js", "example/couch/map/post/comments.js", "example/couch/reduce/sum_length.js", "lib/makura.rb", "lib/makura/database.rb", "lib/makura/design.rb", "lib/makura/error.rb", "lib/makura/filter.rb", "lib/makura/http_methods.rb", "lib/makura/layout.rb", "lib/makura/model.rb", "lib/makura/plugin/localize.rb", "lib/makura/plugin/pager.rb", "lib/makura/server.rb", "lib/makura/uuid_cache.rb", "lib/makura/version.rb", "makura.gemspec", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/gem_setup.rake", "tasks/git.rake", "tasks/grancher.rake", "tasks/manifest.rake", "tasks/metric_changes.rake", "tasks/rcov.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/todo.rake", "tasks/traits.rake"]
  s.homepage = "http://github.com/manveru/makura"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Ruby wrapper around the CouchDB REST API."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0.8.1"])
    else
      s.add_dependency(%q<rest-client>, [">= 0.8.1"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0.8.1"])
  end
end
