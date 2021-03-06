# docbook_status

A utility for DocBook authors/publishers showing the document structure (sections) and word count of a DocBook project. It is intended to provide an overview of a DocBook project's structure and size while you are writing or editing it.

## Features

* lists the section hierarchy (set, book, ... section, simplesect) of a DocBook file
* calculates a word count for each section (words in paras, simparas and formalparas)
* works with included sections (XInclude)
* finds and lists remarks (remarks are not included in the word count)
* output in YAML and JSON format (optional)
* tracks writing progress

## Synopsis

docbook_status is mainly a comandline application, bin/docbook_status, which helps with writing and editing DocBook 5 documents. The application provides information about the content of a DocBook project. That project can consist of a single file or of several files that are included in the master file via XInclude.

To run docbook_status:

   `docbook_status myproject.xml`

This will show the section hierarchy and the word count of the individual sections of myproject.xml.

If the file contains editing remarks, you could list them, too:

   `docbook_status --remarks myproject.xml`

Here docbook_status looks for all _remark_ elements. The application uses the same convention as many source code tools: if the content of the remark element starts with a all-uppercase word, like FIXME or TODO, this will be listed as the remark type, otherwise just REMARK will be used.

If there are many remarks and you just want to concentrate on the most important ones, let's say the FIXMEs, you could restrict the listing with:

   `docbook_status --remarks=FIXME myproject.xml`

If you need to preprocess the XML before feeding it to docbook_status, there is an option for that:

   `docbook_status --pre "asciddoc -bdocbook50 myproject.txt" myproject.xml`

--pre takes shell commands as arguments and executes them before starting the analysis on the XML file.

## Tracking writing progress

As an experiment docbook_status provides features to define and track writing goals/schedules. Currently there are the following options:

* an end date, or deadline, with option --end=\[YYYY-MM-DD\]
* a total word count goal, with option --total=\[number\]
* a daily word count goal, with option --daily=\[number\]

These features are currently not related, you can use any combination of them. When an end date is defined the application will simply remind you on every run of how many days are left.

If one of this options is used, a file called 'dbs_work.yml' is created in the working directory. This file is used to store the goals and the tracking information. If you want to get rid of all tracking, simply delete this file. To disable a specific kind of tracking, just call the options mentioned above with no arguments. That would delete the defined value. An example:

  `docbook_status --end=2099-01-01 --total=1000000  endofworld.xml`

This call would define the goals: scheduled delivery date of 2099-01-01, and a total document size of one million words. To disable the time tracking call it again with no argument:

  `docbook_status --end endofworld.xml`

This would delete the defined delivery date but not the total. Once defined the goal options must not be repeated, since they are stored in the 'dbs_work.yml' file.


## Integration, Customization

In the unlikely case that you don't like the standard screen output and would prefer to replace it, there are other output formats available, JSON and YAML, which make that possible. Normally all output is formatted for output on a terminal screen, but the option _--outputformat_ alllows to specify a different output format, that is printed to STDOUT. Using that you could create your own frontend or integrate the application with other tools (like editors).

Use

   `docbook_status --outputformat=yaml`
or
   `docbook_status --outputformat=json`

to get YAML or JSON structures back. The structure returned is equivalent to the normal terminal output:

* file - path to XML file
* modified - the modification time of the XML file

* sections - an array of section entries, each with
  * title - section name
  * words - word count
  * level - section level in the document hierarchy
  * tag - the section's DocBook tag

* remarks - (optional) an array of remark entries, each with
  * keyword - uppercase keyword, e.g. REMARK, FIXME
  * text - remark text
  * file - file name, location of the remark
  * line - line number, location of the remark

* goals - (optional) information about the defined writing goals
  * start - start date of the tracking
  * end - scheduled end date or nil
  * goal_total - planned total word count or 0
  * goal_daily - planned daily word count or 0

* today - (optional) document size information
  * min - minimum no. of words
  * max - maximum no. of words
  * start - first word count
  * end - last (current) word count
  * ctr - number of runs

## Download

https://rubygems.org/gems/docbook_status

## Requirements

* libxml2
* json (optional, install the gem if you want JSON output for Ruby 1.8)
* win32console (optional, install the gem if you want color support on MS Windows)

## Install

* gem install docbook_status

## Homepage

https://github.com/rvolz/docbook_status/

## License

The MIT License

Copyright (c) 2011-19 Rainer Volz

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
