class UserNameComponent < ViewComponent::Base
  with_collection_parameter :user

  def initialize(user:)
    @name = user.name
  end
end
