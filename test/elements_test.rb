require_relative "test_helper"

class ElementsTest < Minitest::Test
  include PandocElementHelper

  def test_space
    element = space
    assert_equal([], element.contents)
    assert element.is_a?(PandocObjectFilters::Element::Inline)
  end

  def test_str
    str = hello_str
    assert_equal("hello", str.contents)
    assert_equal("hello", str.value)
    assert str.is_a?(PandocObjectFilters::Element::Inline)
  end

  def test_para
    elements = [hello_str, space, world_str]
    para = para(*elements)
    assert_equal(elements, para.contents)
    assert_equal(elements, para.elements)
    assert para.is_a?(PandocObjectFilters::Element::Block)
  end

  def test_link
    link = PandocObjectFilters::Element::Link.new([
                                                    PandocObjectFilters::Element::Attr.new(["id", %w(class1 class2), [%w(key1 value1), %w(key2 value2)]]),
                                                    [PandocObjectFilters::Element::Str.new("link")],
                                                    PandocObjectFilters::Element::Target.new(["http://example.com", "This is the title"])
                                                  ])

    assert_equal("id", link.attributes.identifier)
    assert_equal(%w(class1 class2), link.attributes.classes)
    assert_equal([%w(key1 value1), %w(key2 value2)], link.attributes.key_values)
    assert_equal("value1", link.attributes["key1"])
    assert_equal("value2", link.attributes["key2"])
    assert_equal(nil, link.attributes["key3"])
    assert_equal(true, link.attributes.include?("key1"))
    assert_equal(true, link.attributes.include?("key2"))
    assert_equal(false, link.attributes.include?("key3"))
    assert_equal([PandocObjectFilters::Element::Str.new("link")], link.elements)
    assert_equal("http://example.com", link.target.url)
    assert_equal("This is the title", link.target.title)
  end
end
