
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
  url      'http://projekte.textmuch.de/docbook_status/'
}

