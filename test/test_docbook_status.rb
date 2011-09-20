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
    dbs = DocbookStatus::Status.new()
    status = dbs.is_docbook?(non5)
    status.must_be :==, false
  end

  it "input is DocBook 5" do
    non5 = XML::Document.string '<?xml version="1.0"?><article xmlns="http://docbook.org/ns/docbook"/>'
    dbs = DocbookStatus::Status.new()
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
    dbs = DocbookStatus::Status.new()
    ind = XML::Document.string(input)
    sections = dbs.analyze_document(ind)
    sections.must_equal([{:title => 'A1', :words => 17, :level => 0, :tag => 'article'},
                         {:title => 'S1', :words => 17, :level => 1, :tag => 'section'}])
  end

  it "processes includes" do
    dbs = DocbookStatus::Status.new()
    ind = XML::Document.file('test/fixtures/book.xml')
    if (dbs.has_xinclude?(ind))
      ind.xinclude
    end
    sections = dbs.analyze_document(ind)
    sections.must_equal([{:title => 'B1', :words => 71, :level => 0, :tag => 'book'},
                         {:title => 'C1', :words => 54, :level => 1, :tag => 'chapter'},
                         {:title => 'C2', :words => 17, :level => 1, :tag => 'chapter'}])
  end

  it "filters remarks while counting" do
    dbs = DocbookStatus::Status.new()
    ind = XML::Document.file('test/fixtures/chapter2.xml')
    sections = dbs.analyze_document(ind)
    sections.must_equal([{:title => 'C2', :words => 17, :level => 0, :tag => 'chapter'}])
  end

  it "finds and collects all XIncludes URLs in a document" do
    dbs = DocbookStatus::Status.new()
    ind = XML::Document.file('test/fixtures/bookxi.xml')
    xinc = dbs.has_xinclude?(ind)
    xinc.must_equal(true)
    xincs = dbs.find_xincludes(ind)
    xincs.must_equal(["chapter2xi.xml", "chapter3xi.xml", "section1xi.xml"])
  end

  it "finds remarks" do
    dbs = DocbookStatus::Status.new('test/fixtures/book.xml')
    all_remarks = dbs.find_remarks
    #all_remarks = dbs.remarks()
    all_remarks.must_equal([{:keyword=>"REMARK", :text=>"Blindtext auswechseln", :path=>"/*/*[2]/*[3]/*[2]/*", :parent=>"/*/*[2]/*[3]/*[2]", :file=>"book.xml", :line=>15}, {:keyword=>"FIXME", :text=>"Ausbauen.", :path=>"/*/*[2]/*", :parent=>"/*/*[2]", :file=>"chapter2.xml", :line=>6}])
    fixmes = dbs.remarks('FIXME')
    fixmes.must_equal([{:keyword=>"FIXME", :text=>"Ausbauen.", :path=>"/*/*[2]/*", :parent=>"/*/*[2]", :file=>"chapter2.xml", :line=>6}])
  end

end
