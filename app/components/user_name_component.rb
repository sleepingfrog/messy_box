class UserNameComponent < ViewComponent::Base
  def initialize(user:)
    @name = user.name
  end
end
