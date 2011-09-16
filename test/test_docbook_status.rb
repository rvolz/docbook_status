# -*- encoding: utf-8 -*-
require 'minitest/spec'
require 'minitest/autorun'
require "docbook_status"

describe DocbookStatus do
  it "works" do
    true
  end

  it "complains if the input is not DocBook 5" do
    non5 = XML::Document.string '<?xml version="1.0"?><article/>'
    dbs = DocbookStatus.new()
    status = dbs.is_docbook?(non5)
    status.must_be :==, false
  end

  it "input is DocBook 5" do
    non5 = XML::Document.string '<?xml version="1.0"?><article xmlns="http://docbook.org/ns/docbook"/>'
    dbs = DocbookStatus.new()
    status = dbs.is_docbook?(non5)
    status.must_be :==, true
  end

  it "counts correctly" do
    input = <<EOI
<?xml version="1.0" ?>
<article xmlns="http://docbook.org/ns/docbook" version="5.0">
  <title>A1</title>
  <section>
    <title>S1</title>
    <para>
       Dies ist ein Test .. Dies ist ein  Test.
       In den Jahren 1900-1901 geschahen viele Überfälle von O`Reillys.
    </para>
  </section>
</article>
EOI
    dbs = DocbookStatus.new()
    ind = XML::Document.string(input)
    sections = dbs.analyze_document(ind)
    sections.must_equal([['A1', 17, 0, 'article'],['S1', 17, 1, 'section']])
  end

  it "processes includes" do
    dbs = DocbookStatus.new()
    ind = XML::Document.file('test/fixtures/book.xml')
    if (dbs.has_xinclude?(ind))
      ind.xinclude
    end
    sections = dbs.analyze_document(ind)
    sections.must_equal([['B1', 71, 0, 'book'],['C1', 54, 1, 'chapter'],['C2', 17, 1, 'chapter']])
  end

  it "filters remarks while counting" do
    dbs = DocbookStatus.new()
    ind = XML::Document.file('test/fixtures/chapter2.xml')
    sections = dbs.analyze_document(ind)
    sections.must_equal([['C2', 17, 0, 'chapter']])
  end

  it "finds remarks" do
    XML.default_line_numbers=true
    dbs = DocbookStatus.new()
    ind = XML::Document.file('test/fixtures/book.xml')
    if (dbs.has_xinclude?(ind))
      ind.xinclude
    end
    sections = dbs.analyze_document(ind)
    all_remarks = dbs.remarks()
    all_remarks.must_equal([{:keyword=>"BLINDTEXT", :text=>"auswechseln", :path=>"/*/*[2]/*[3]/*[2]/*", :parent=>"/*/*[2]/*[3]/*[2]", :line=>15}, {:keyword=>"FIXME", :text=>"Ausbauen.", :path=>"/*/*[3]/*[2]/*", :parent=>"/*/*[3]/*[2]", :line=>6}])
    fixmes = dbs.remarks('FIXME')
    fixmes.must_equal([{:keyword => 'FIXME', :text => 'Ausbauen.', :path => '/*/*[3]/*[2]/*', :parent => '/*/*[3]/*[2]', :line => 6}])
  end

  it "finds and collects all XIncludes URLs in a document" do
    input = <<EOI
<?xml version="1.0" ?>
<article
 xmlns="http://docbook.org/ns/docbook" version="5.0"
 xmlns:xi="http://www.w3.org/2001/XInclude">
  <title>A1</title>
  <section>
    <title>S1</title>
    <para>
       Dies ist ein Test .. Dies ist ein  Test.
       In den Jahren 1900-1901 geschahen viele Überfälle von O`Reillys.
    </para>
  </section>
  <xi:include href="s2.xml"/>
  <xi:include href="file://x/s3.xml"/>
  <para>
    Bla, bla, bla
  </para>
  <xi:include href="http://example.org/s4.xml"/>
</article>
EOI
    dbs = DocbookStatus.new()
    ind = XML::Document.string(input)
    xinc = dbs.has_xinclude?(ind)
    xinc.must_equal(true)
    xincs = dbs.find_xincludes(ind)
    xincs.must_equal(['s2.xml','file://x/s3.xml','http://example.org/s4.xml'])
  end
end
