# -*- encoding: utf-8 -*-

require 'xml'

# Analyzes DocBook 5 documents for document structure (sections) and text length.
#
class DocbookStatus

  # :stopdoc
  #
  PATH = File.expand_path('../..', __FILE__) + File::SEPARATOR
  LIBPATH = File.expand_path('..', __FILE__) + File::SEPARATOR
  VERSION = File.read(PATH + '/version.txt').strip
  HOME = File.expand_path(ENV['HOME'] || ENV['USERPROFILE'])
  #
  # :startdoc

  # The DocBook 5 namespace URL
  #
  DOCBOOK_NS = 'http://docbook.org/ns/docbook'

  # The XInclude namespace URL
  #
  XINCLUDE_NS = 'http://www.w3.org/2001/XInclude'

  # Elements whose contents is counted as text. The _formalpara_
  # elements are included implicitly because they contain _para_ child
  # elements.
  #
  @@text_elements = ['para','simpara']

  # Section elements, following the list given in http://docbook.org/tdg5/en/html/ch02.html#roots
  # except for the refsect... elements.
  #
  @@section_elements = %w[
    acknowledgements appendix article
    bibliography book
    chapter colophon
    dedication
    glossary
    index
    preface
    section sect1 sect2 sect3 sect4 set simplesect
    toc
  ]

  def initialize
    @sections = []
  end

  # Returns the version of docbook_status
  #
  def self.version
    VERSION
  end

  # Counts the words in the contents of the given node. _Word_ in this
  # context means something that is delimited by _space_ charactes and starts with
  # _word_ characters (in the regexp sense).
  #
  def count_words(node)
    words = node.content.strip.split(/[[:space:]]+/).find_all {|w| w =~ /\w+/}
    words.size
  end

  # Find the _title_ of the current section. That element is either
  # directly following or inside an _info_ element. Return the empty
  # string if no title can be found.
  #
  def find_section_title(node)
    title = node.find_first('./db:title')
    if title.nil?
      title = node.find_first './db:info/db:title'
    end
    if title.nil?
      ""
    else
      title.content
    end
  end

  # Check the document elements for content and type recursively,
  # starting at the current node.  Returns an array with paragraph and
  # section maps.
  #
  def check_node(node, level, ctr)
    if (@@text_elements.include? node.name)
      ctr << {:type => :para, :level => level, :words => count_words(node)}
    elsif (@@section_elements.include? node.name)
      title = find_section_title(node)
      ctr << {:type => :section, :level => level, :title => title, :name => node.name}
    end
    node.children.each {|inner_elem| check_node(inner_elem, level+1, ctr)} if node.children?
    ctr
  end

  # Check whether the document has a DocBook default namespace
  def is_docbook?(doc)
    dbns = doc.root.namespaces.default
    (!dbns.nil? && (dbns.href.casecmp(DOCBOOK_NS) == 0))
  end

  # Check whether the document has a XInclude namespace
  def has_xinclude?(doc)
    ret = false
    doc.root.namespaces.each do |ns|
      if (ns.href.casecmp(XINCLUDE_NS) == 0)
        ret = true
        break
      end
    end
    ret
  end

  # Searches the XML document for sections and word counts. Returns an
  # array of sections with their word counts.
  #
  def analyze_document(doc)
    # Add a namespace declaration for XPath expressions
    doc.root.namespaces.default_prefix = 'db'
    # Analyze the document starting with the root node
    doc_maps = check_node(doc.root,0,[])
    @sections = []
    section_name = doc_maps[0][:title]
    section_type = doc_maps[0][:name]
    section_ctr = 0
    section_level = 0
    doc_ctr = 0
    #puts doc_maps.inspect
    xms = doc_maps.drop(1)
    # Compute word counts per section
    xms.each do |m|
      if (m[:type] == :para)
        doc_ctr += m[:words]
        section_ctr += m[:words]
      else
        @sections << [section_name,section_ctr,section_level,section_type]
        section_name = m[:title]
        section_ctr = 0
        section_level = m[:level]
        section_type = m[:name]
      end
    end
    @sections << [section_name,section_ctr,section_level,section_type]
    # Put the document word count near the document type
    @sections[0][1] = doc_ctr
    @sections
  end

end
