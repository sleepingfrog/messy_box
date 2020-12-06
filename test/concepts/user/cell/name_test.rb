require 'test_helper'

class UserCellNameTest < ActiveSupport::TestCase
  def test_render_cell
    user = User.new(name: 'user1')
    result = User::Cell::Name.call(user).call
    doc = Nokogiri::HTML(result)

    assert_includes(doc.css('div span').to_html, user.name)
  end
end
