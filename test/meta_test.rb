require_relative "test_helper"

class MetaTest < Minitest::Test
  include PandocAstHelper
  include PandocHelper
  include PandocVersionHelper

  def test_null
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::Meta, object.meta.class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => {} }
      end

      v "1.17" do
        {}
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_empty
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::Meta, object.meta.class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => {} }
      end

      v "1.17" do
        {}
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_string
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: 123
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaString, object.meta["key"].class
    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaString", "123") } }
      end

      v "1.17" do
        { "key" => ast("MetaString", "123") }
      end
    end
    assert_equal expected_ast, object.meta.to_ast
  end

  def test_bool
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: true
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaBool, object.meta["key"].class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaBool", true) } }
      end

      v "1.17" do
        { "key" => ast("MetaBool", true) }
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_list
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key:
      - 123
      - 456
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaList, object.meta["key"].class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaList", [ast("MetaString", "123"), ast("MetaString", "456")]) } }
      end

      v "1.17" do
        { "key" => ast("MetaList", [ast("MetaString", "123"), ast("MetaString", "456")]) }
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_map
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key:
        key1: 123
        key2: 456
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaMap, object.meta["key"].class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaMap", "key1" => ast("MetaString", "123"), "key2" => ast("MetaString", "456")) } }
      end

      v "1.17" do
        { "key" => ast("MetaMap", "key1" => ast("MetaString", "123"), "key2" => ast("MetaString", "456")) }
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_inlines
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: hello world
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaInlines, object.meta["key"].class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaInlines", [ast("Str", "hello"), ast("Space"), ast("Str", "world")]) } }
      end

      v "1.17" do
        { "key" => ast("MetaInlines", [ast("Str", "hello"), ast("Space"), ast("Str", "world")]) }
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end

  def test_blocks
    object = PandocObjectFilters::Element::Document.new to_pandoc_ast(<<-EOF)
      ---
      key: |
          <p>
          Contents
          </p>
      ---
      Contents
    EOF

    assert_equal PandocObjectFilters::Element::MetaBlocks, object.meta["key"].class

    expected_ast = versioned do
      v "1.16" do
        { "unMeta" => { "key" => ast("MetaBlocks", [ast("RawBlock", ["html", "<p>"]), ast("Plain", [ast("Str", "Contents")]), ast("RawBlock", ["html", "</p>"])]) } }
      end

      v "1.17" do
        { "key" => ast("MetaBlocks", [ast("RawBlock", ["html", "<p>"]), ast("Plain", [ast("Str", "Contents")]), ast("RawBlock", ["html", "</p>"])]) }
      end
    end

    assert_equal expected_ast, object.meta.to_ast
  end
end
