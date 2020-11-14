FactoryBot.define do
  sequence :position

  factory :user_todo, class: UserTodo do
    content { 'todo content' }
    position { generate(:position) }
  end
end
