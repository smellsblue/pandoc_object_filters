require_relative 'test_helper'

class ToAstTest < Minitest::Test
  include PandocHelper
  include PandocAstHelper
  include PandocElementHelper

  def test_space
    assert_equal(space_ast, space.to_ast)
  end

  def test_str
    assert_equal(hello_str_ast, hello_str.to_ast)
  end

  def test_with_object
    assert_equal(space_ast, PandocObjectFilters::Element.to_ast(space))
  end

  def test_with_array
    expected = [hello_str_ast, space_ast, world_str_ast]
    actual = PandocObjectFilters::Element.to_ast([hello_str, space, world_str])
    assert_equal(expected, actual)
  end

  def test_with_hash
    expected = { 'x' => 'value', 'y' => space_ast }
    actual = PandocObjectFilters::Element.to_ast('x' => 'value', 'y' => space)
    assert_equal(expected, actual)
  end

  def test_with_string
    assert_equal('hello', PandocObjectFilters::Element.to_ast('hello'))
  end

  def test_para
    expected = para_ast(hello_str_ast, space_ast, world_str_ast)
    actual = para(hello_str, space, world_str).to_ast
    assert_equal(expected, actual)
  end

  def test_link
    expected = ast('Link', [
      ['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]],
      [ast('Str', 'link')],
      ['http://example.com', 'This is the title']
    ])

    actual = PandocObjectFilters::Element::Link.new([
      PandocObjectFilters::Element::Attr.new(['id', ['class1', 'class2'], [['key1', 'value1'], ['key2', 'value2']]]),
      [PandocObjectFilters::Element::Str.new('link')],
      PandocObjectFilters::Element::Target.new(['http://example.com', 'This is the title'])
    ]).to_ast

    assert_equal(expected, actual)
  end
end
