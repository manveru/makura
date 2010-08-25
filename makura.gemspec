# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{makura}
  s.version = "2010.08.26"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael 'manveru' Fellinger"]
  s.date = %q{2010-08-26}
  s.default_executable = %q{makura}
  s.email = %q{m.fellinger@gmail.com}
  s.executables = ["makura"]
  s.files = ["AUTHORS", "CHANGELOG", "COPYING", "MANIFEST", "README.md", "Rakefile", "bin/makura", "doc/AUTHORS", "doc/CHANGELOG", "example/blog.rb", "example/couch/map/author_all.js", "example/couch/map/author_posts.js", "example/couch/map/post_all.js", "example/couch/map/post_comments.js", "example/couch/reduce/sum_length.js", "lib/makura.rb", "lib/makura/database.rb", "lib/makura/design.rb", "lib/makura/error.rb", "lib/makura/http_methods.rb", "lib/makura/layout.rb", "lib/makura/model.rb", "lib/makura/plugin/localize.rb", "lib/makura/plugin/pager.rb", "lib/makura/server.rb", "lib/makura/uuid_cache.rb", "lib/makura/version.rb", "makura.gemspec", "tasks/authors.rake", "tasks/bacon.rake", "tasks/changelog.rake", "tasks/copyright.rake", "tasks/gem.rake", "tasks/gem_installer.rake", "tasks/gem_setup.rake", "tasks/git.rake", "tasks/grancher.rake", "tasks/manifest.rake", "tasks/metric_changes.rake", "tasks/rcov.rake", "tasks/release.rake", "tasks/reversion.rake", "tasks/setup.rake", "tasks/todo.rake", "tasks/traits.rake", "tasks/yard.rake", "tasks/ycov.rake"]
  s.homepage = %q{http://github.com/manveru/makura}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Ruby wrapper around the CouchDB REST API.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
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
