# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2019-04-19

* Updated dependencies for Ruby 2.5
* Updated tests

## [1.0.1] - 2012-12-23

* Updated documentation url

## [1.0.0] - 2012-07-04

* Updated version to 1.0, 0.5 had few and tiny bug reports 
* Empty remarks are now properly handled and signaled.
* Improved Ruby 1.8.7 support for status history.

## [0.5.0] - 2011-10-15

* Removed the daemon functionality, it didn't work across platforms. Use Guard instead.
* Improved the platform compatibility. Should now work better on Windows.
* Color support is now optional on Windows. Is switched on if gem 'win32console' is available.
* JSON support is now optional. Is switched on if the json library (1.9) or gem (1.8) is available.

## [0.4.0] - 2011-10-04

* Minor changes
  * The word counts displayed are now the totals of the respective section, including all its children
  * Changed remarks output, more space for file names and content
  * Changed the homepage to GitHub

## [0.3.0] - 2011-09-28

* Writing goals (total and daily) can be defined and tracked
* Added YAML and JSON output formats, available with option --outputformat
* Minor fixes
  * Removed daemon state persistence file dw_state.yml
  * Colorized screen output
  * Reorganized library

## [0.2.1] - 2011-09-18

* Minor fixes for Gem packaging

## [0.2.0] - 2011-09-18

* Added remarks listing.
* Minor fixes
  * removed _formalpara_ from the list of countable text elements because they contain _para_ elements

## [0.1.1] - 2011-09-07

* Documentation corrections

## 0.1.0 / 2011-09-07

* Initial version
