require_relative "test_helper"

class ToObjectsTest < Minitest::Test
  include PandocHelper
  include PandocAstHelper
  include PandocElementHelper

  def test_space
    assert_equal(space, PandocObjectFilters::Element.to_object(space_ast))
  end

  def test_str
    assert_equal(hello_str, PandocObjectFilters::Element.to_object(hello_str_ast))
  end

  def test_with_array
    expected = [hello_str, space, world_str]
    actual = PandocObjectFilters::Element.to_object([hello_str_ast, space_ast, world_str_ast])
    assert_equal(expected, actual)
  end

  def test_with_non_ast_hash
    expected = { "x" => "value", "y" => space }
    actual = PandocObjectFilters::Element.to_object("x" => "value", "y" => space_ast)
    assert_equal(expected, actual)
  end

  def test_with_string
    assert_equal("hello", PandocObjectFilters::Element.to_object("hello"))
  end

  def test_para
    expected = para(hello_str, space, world_str)
    actual = PandocObjectFilters::Element.to_object(para_ast(hello_str_ast, space_ast, world_str_ast))
    assert_equal(expected, actual)
  end

  def test_link
    expected = PandocObjectFilters::Element::Link.new([
                                                        PandocObjectFilters::Element::Attr.new(["id", %w(class1 class2), [%w(key1 value1), %w(key2 value2)]]),
                                                        [PandocObjectFilters::Element::Str.new("link")],
                                                        PandocObjectFilters::Element::Target.new(["http://example.com", "This is the title"])
                                                      ])

    actual = PandocObjectFilters::Element.to_object(ast("Link", [
                                                          ["id", %w(class1 class2), [%w(key1 value1), %w(key2 value2)]],
                                                          [ast("Str", "link")],
                                                          ["http://example.com", "This is the title"]
                                                        ]))

    assert_equal(expected, actual)
  end
end
