# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{docbook_status}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rainer Volz"]
  s.date = %q{2011-09-08}
  s.default_executable = %q{docbook_status}
  s.description = %q{A utility for DocBook authors/publishers showing the document structure (sections) and word count of a DocBook project. It is intended to provide an overview of a DocBook project's structure and volume while you are writing or editing it.}
  s.email = %q{dev@textmulch.de}
  s.executables = ["docbook_status"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/docbook_status"]
  s.files = [".bnsignore", "Gemfile", "Gemfile.lock", "History.txt", "README.txt", "Rakefile", "bin/docbook_status", "lib/docbook_status.rb", "spec/docbook_status_spec.rb", "spec/spec_helper.rb", "test/fixtures/book.xml", "test/fixtures/chapter2.xml", "test/test_docbook_status.rb", "version.txt"]
  s.homepage = %q{http://projekte.textmuch.de/docbook_status/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{docbook_status}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A utility for DocBook authors/publishers showing the document structure (sections) and word count of a DocBook project.}
  s.test_files = ["test/test_docbook_status.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 3.7.1"])
    else
      s.add_dependency(%q<bones>, [">= 3.7.1"])
    end
  else
    s.add_dependency(%q<bones>, [">= 3.7.1"])
  end
end
