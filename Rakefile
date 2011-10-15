#-*- encoding: utf-8 ; mode:ruby -*-
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'docbook_status'
  authors  'Rainer Volz'
  email    'dev@textmulch.de'
  url      'http://rvolz.github.com/docbook_status/'
  ignore_file  '.gitignore'
  exclude       << 'dbs-about.org'
  depend_on     'libxml-ruby'
  depend_on     'term-ansicolor'
  depend_on     'zucker'
}
