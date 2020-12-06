require 'test_helper'

class UserNameComponentTest < ViewComponent::TestCase
  def test_render_component
    user = User.new(name: 'user1')
    result = render_inline(UserNameComponent.new(user: user))

    assert_includes(result.css('div span').to_html, user.name)
  end
end
