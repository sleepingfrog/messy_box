# frozen_string_literal: true

user1 = User.create(email: 'user1@example.org', name: 'user1', password: 'password')
User.create(email: 'user2@example.org', name: 'user2', password: 'password')
User.create(email: 'user3@example.org', name: 'user3', password: 'password')

1.upto(5) do |i|
  user1.todos.build(position: i, content: 'todo')
end
user1.save!
