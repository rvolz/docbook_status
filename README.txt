= docbook_status

A utility for DocBook authors/publishers showing the document structure (sections) and word count of a DocBook project. It is intended to provide an overview of a DocBook project's structure and volume while you are writing or editing it.

	
== Features

* lists all sections (set, book, ... section, simplesect) in a DocBook file
* calculates a word count for each section (words in paras, simparas and formalparas)
* works with included sections (XInclude)

== Examples

The package includes a comandline application, bin/docbook_status, that can be used in two ways:

to run it manually, once:
   docbook_status <DocBook file>

to run the application in demon mode, continually:
   docbook_status --demon --glob "*.xml" --dir "." <DocBook file>
   
In demon-mode the application checks the files matched by the _glob_ pattern in the directory specified by _dir_ for changes, and redisplays the document analysis whenever a change occures. The demon can be termanted by simply pressing RETURN. 

== Download

https://rubygems.org/gems/docbook_status

== Requirements

* libxml2

== Install

* gem install docbook_status

== License

The MIT License

Copyright (c) 2011 Rainer Volz

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
