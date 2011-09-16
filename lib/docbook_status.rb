# -*- encoding:utf-8 -*-

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
    part preface
    section sect1 sect2 sect3 sect4 set simplesect
    toc
  ]

  def initialize
    @sections = []
    XML.default_line_numbers=true
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

  # Counts the words in the contents of the given node.
  # It is assumed that the node is a kind of pure content (a paragraph) and therefore everything in it
  # should be included in the word count. An exception to this are
  # _remark_ elements, which are conisdered as comments, not meant for final publication.
  #
  def count_content_words(node)
    ws = count_words(node)
    # Count the remark text contained in the paragraph and subtract it from the real thing
    wsr = node.find('db:remark').reduce(0) {|m,r| m+count_words(r)}
    ws - wsr
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
      ctr << {:type => :para, :level => level, :words => count_content_words(node)}
    elsif (@@section_elements.include? node.name)
      title = find_section_title(node)
      ctr << {:type => :section, :level => level, :title => title, :name => node.name}
      node.children.each {|inner_elem| check_node(inner_elem, level+1, ctr)} if node.children?
    else
      node.children.each {|inner_elem| check_node(inner_elem, level+1, ctr)} if node.children?
    end

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

  # Finds and returns all XInclude files/URLs in a document.
  #
  # OPTIMIZE implement xpointer and fallback handling for
  # xi:include? see http://www.w3.org/TR/xinclude/
  #
  def find_xincludes(doc)
    xincs = doc.find('//xi:include', "xi:"+XINCLUDE_NS)
    xincs.map {|x| x.attributes['href'] }
  end

  # Find all remark elements in the document and return a map for
  # every such element. The map contains:
  #
  # * keyword: the first word of the content in uppercase (if the remark contains text), else the empty string
  # * text: the content of the remark element, minus the keyword
  # * path: the XPath of the remark element
  # * parent: the XPath of the remark's parent
  # * line: the line number in the source file
  #
  def find_remarks(doc)
    rems = doc.find('//db:remark')
    rems.map {|rem|
      c = rem.content.strip
      kw = ''
      if rem.first.text?
        kw1 = c.match('^\w+')
        unless kw1.nil?
          kw = kw1[0].upcase
          c = kw1.post_match.lstrip
        end
      end
      {:keyword => kw, :text => c , :path => rem.path, :parent => rem.parent.path, :line => rem.line_num}
    }
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
    @remarks = []
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
    # Find all remarks
    @remarks = find_remarks(doc)
    @sections
  end

  # Return the remark-elements found in the document. If _keyword_ is
  # nil then return all remarks, else only the ones with the right
  # keyword.
  #
  def remarks(keyword=nil)
    if keyword.nil?
      @remarks
    else
      ukw = keyword.upcase
      @remarks.find_all {|r| r[:keyword] == (ukw)}
    end
  end

end
