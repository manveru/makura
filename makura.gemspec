# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{makura}
  s.version = "2013.03.28"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Michael 'manveru' Fellinger}]
  s.date = %q{2012-12-01}
  s.email = %q{m.fellinger@gmail.com}
  s.executables = [%q{makura}]
  s.files = [%q{.gems}, %q{.rvmrc}, %q{AUTHORS}, %q{CHANGELOG}, %q{COPYING}, %q{MANIFEST}, %q{README.md}, %q{Rakefile}, %q{bin/makura}, %q{doc/AUTHORS}, %q{doc/CHANGELOG}, %q{example/blog.rb}, %q{example/couch/filter/post/created_by.js}, %q{example/couch/filter/post/shorter_than.js}, %q{example/couch/map/author/all.js}, %q{example/couch/map/author/posts.js}, %q{example/couch/map/post/all.js}, %q{example/couch/map/post/comments.js}, %q{example/couch/reduce/sum_length.js}, %q{lib/makura.rb}, %q{lib/makura/database.rb}, %q{lib/makura/design.rb}, %q{lib/makura/error.rb}, %q{lib/makura/filter.rb}, %q{lib/makura/http_methods.rb}, %q{lib/makura/layout.rb}, %q{lib/makura/model.rb}, %q{lib/makura/plugin/localize.rb}, %q{lib/makura/plugin/pager.rb}, %q{lib/makura/server.rb}, %q{lib/makura/uuid_cache.rb}, %q{lib/makura/version.rb}, %q{makura.gemspec}, %q{tasks/authors.rake}, %q{tasks/bacon.rake}, %q{tasks/changelog.rake}, %q{tasks/copyright.rake}, %q{tasks/gem.rake}, %q{tasks/gem_installer.rake}, %q{tasks/gem_setup.rake}, %q{tasks/git.rake}, %q{tasks/grancher.rake}, %q{tasks/manifest.rake}, %q{tasks/metric_changes.rake}, %q{tasks/rcov.rake}, %q{tasks/release.rake}, %q{tasks/reversion.rake}, %q{tasks/setup.rake}, %q{tasks/todo.rake}, %q{tasks/traits.rake}]
  s.homepage = %q{http://github.com/manveru/makura}
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Ruby wrapper around the CouchDB REST API.}

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
