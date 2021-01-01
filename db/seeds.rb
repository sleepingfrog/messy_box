# frozen_string_literal: true

def print_seed(message)
  puts message
  yield
  puts message + ' done!'
end

print_seed('todo seed') do
  user1 = User.create(email: 'user1@example.org', name: 'user1', password: 'password')
  User.create(email: 'user2@example.org', name: 'user2', password: 'password')
  User.create(email: 'user3@example.org', name: 'user3', password: 'password')

  1.upto(5) do |i|
    user1.todos.build(position: i, content: 'todo')
  end
  user1.save!
end

print_seed('article') do
  a = Article.new(title: 'Title1', body: 'body1' * 10)
  a.tags << Tag.find_or_create_by(name: 'tag1')
  a.tags << Tag.find_or_create_by(name: 'tag2')
  a.tags << Tag.find_or_create_by(name: 'tag3')
  a.tags << Tag.find_or_create_by(name: 'tag4')
  a.tags << Tag.find_or_create_by(name: 'tag5')
  a.save!

  a = Article.new(title: 'Title2', body: 'body2' * 10)
  a.tags << Tag.find_or_create_by(name: 'tag1')
  a.tags << Tag.find_or_create_by(name: 'tag2')
  a.tags << Tag.find_or_create_by(name: 'tag3')
  a.save!

  a = Article.new(title: 'Title2', body: 'body2' * 10)
  a.tags << Tag.find_or_create_by(name: 'tag1')
  a.tags << Tag.find_or_create_by(name: 'tag2')
  a.tags << Tag.find_or_create_by(name: 'tag3')
  a.tags << Tag.find_or_create_by(name: 'tag4')
  a.tags << Tag.find_or_create_by(name: 'tag5')
  a.save!
end
