 # -*- encoding:utf-8 -*-

require 'xml'
module DocbookStatus

 # Analyzes DocBook 5 documents for document structure (sections) and text length.
 #
 class Status

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

   attr_reader :doc

   def initialize(fname=nil)
     @sections = []
     @remarks = []
     @source = fname
     @source_dir = fname.nil? ? nil : File.dirname(fname)
     @source_file = fname.nil? ? nil : File.basename(fname)
     @doc = nil
     XML.default_line_numbers=true
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
     if has_xinclude?(doc)
       xincs = doc.find('//xi:include', "xi:"+XINCLUDE_NS)
       xfiles = xincs.map {|x| x.attributes['href'] }
       (xfiles << xfiles.map {|xf|
                    xfn = File.exists?(xf) ? xf : File.expand_path(xf,File.dirname(doc.root.base_uri))
                    xdoc = XML::Document.file(xfn)
                    find_xincludes(xdoc)
                  }).flatten
     else
       []
     end
   end

   # Find all remark elements in the document and return a map for
   # every such element. The map contains:
   #
   # * keyword: if the first word of the content is uppercase that is the keyword, else _REMARK_
   # * text: the content of the remark element, minus the keyword
   # * path: the XPath of the remark element
   # * parent: the XPath of the remark's parent
   # * line: the line number in the source file
   #
   # OPTIMIZE look for 'role' attributes as keywords?
   #
   def find_remarks_in_doc(doc,source)
     rems = doc.find('//db:remark')
     rems.map {|rem|
       c = rem.content.strip
       kw = 'REMARK'
       if rem.first.text?
         kw1 = c.match('^([[:upper:]]+)([[:space:][:punct:]]|$)')
         unless kw1.nil?
           kw = kw1[1]
           c = kw1.post_match.lstrip
         end
       end
       {:keyword => kw, :text => c , :path => rem.path, :parent => rem.parent.path,
         :file=>source, :line => rem.line_num}
     }
   end

   # Finds the remarks by looking through all the Xincluded files
   #
   def find_remarks(filter=[])
     if (@source.nil?)
       rfiles = find_xincludes(@doc)
     else
       @doc = XML::Document.file(@source)
       rfiles = [@source_file] + find_xincludes(@doc)
     end
     @remarks = rfiles.map {|rf|
       ind = XML::Document.file(File.expand_path(rf,@source.nil? ? '.' : @source_dir))
       ind.root.namespaces.default_prefix = 'db'
       rems = find_remarks_in_doc(ind, rf)
       rems
     }.flatten
     if (filter.empty?)
       @remarks
     else
       filter.map {|f|
         @remarks.find_all {|r| f.casecmp(r[:keyword]) == 0}
       }.flatten
     end
   end

   # Searches the XML document for sections and word counts. Returns an
   # array of sections (map) with title, word count, section level and DocBook tag.
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
         @sections << {:title => section_name, :words => section_ctr, :level => section_level, :tag => section_type}
         section_name = m[:title]
         section_ctr = 0
         section_level = m[:level]
         section_type = m[:name]
       end
     end
     @sections << {:title => section_name, :words => section_ctr, :level => section_level, :tag => section_type}
     # Put the document word count near the document type
     @sections[0][:words] = doc_ctr
     @sections
   end

   # Open the XML document, check for the DocBook5 namespace and finally
   # apply Xinclude tretement to it, if it has a XInclude namespace.
   #
   def analyze_file
     @doc = XML::Document.file(@source)
     raise ArgumentError, "Error: #{@source} is apparently not DocBook 5." unless is_docbook?(@doc)
     @doc.xinclude if has_xinclude?(@doc)
     analyze_document(@doc)
   end

 end
end
