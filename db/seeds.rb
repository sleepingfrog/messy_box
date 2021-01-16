# frozen_string_literal: true

FFaker::Random.seed = 12345
random = Random.new(12345)

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
  1.upto(20) do |i|
    a = Article.new(title: "Title#{i}", body: FFaker::LoremJA.paragraph)
    1.upto(random.rand(5)) do
      a.tags << Tag.find_or_create_by(name: FFaker::JobJA.title)
    end
    a.save!
  end

  Article.create_index!
  Article.__elasticsearch__.import scope: :with_tags
end
