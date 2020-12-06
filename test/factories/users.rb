# frozen_string_literal: true
FactoryBot.define do
  sequence :email do |n|
    "example#{n}@example.com"
  end

  factory :user, class: User do
    email { generate(:email) }
    password { 'password' }

    trait :with_todos do
      after(:build) do |user|
        user.todos << FactoryBot.build(:user_todo)
        user.todos << FactoryBot.build(:user_todo)
        user.todos << FactoryBot.build(:user_todo)
      end
    end
  end
end
