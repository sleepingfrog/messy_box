# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
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
