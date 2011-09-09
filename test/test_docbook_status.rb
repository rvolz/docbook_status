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

end
