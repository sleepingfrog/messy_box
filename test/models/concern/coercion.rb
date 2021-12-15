require 'test_helper'

class ConcernCoercionText < ActiveSupport::TestCase

  class Foo
    include CoercionAttributes

    coersion_attr :attr1, [1, :one, 'one']
  end

  setup do
    @foo = Foo.new
  end

  test 'coersion for options' do
    @foo.attr1 = 1
    assert_equal 1, @foo.attr1

    @foo.attr1 = :one
    assert_equal :one, @foo.attr1

    @foo.attr1 = 'one'
    assert_equal 'one', @foo.attr1

    @foo.attr1 = 'いち'
    assert_nil @foo.attr1
  end
end
