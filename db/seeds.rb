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
  1.upto(200) do |i|
    a = Article.new(title: "Title#{i}", body: FFaker::LoremJA.paragraph)
    1.upto(random.rand(5)) do
      a.tags << Tag.find_or_create_by(name: FFaker::JobJA.title)
    end
    a.save!
  end

  Article.create_index!
  Article.__elasticsearch__.import(scope: :with_tags)
end

print_seed('frame_size') do
  FrameSize.create!(name: 'size1', width: 1, height: 1)
  FrameSize.create!(name: 'size2', width: 1, height: 2)
  FrameSize.create!(name: 'size3', width: 2, height: 1)
  FrameSize.create!(name: 'size4', width: 2, height: 2)
  FrameSize.create!(name: 'size5', width: 1, height: 3)
  FrameSize.create!(name: 'size6', width: 3, height: 1)
  FrameSize.create!(name: 'size7', width: 2, height: 3)
  FrameSize.create!(name: 'size8', width: 3, height: 2)
end

print_seed('book') do
  page_sizes = [
    PageSize.create!(name: 'name1', width: 4, height: 4),
    PageSize.create!(name: 'name2', width: 10, height: 8),
  ]
  book = Book.new(title: 'title1', description: 'description1')
  [
    { position: 1, page_count: 1, page_offset: 0 },
    { position: 2, page_count: 2, page_offset: 1 },
  ].each do |attrs|
    book.chapters.build(**attrs).tap do |chapter|
      1.upto(attrs[:page_count]) do |i|
        chapter.pages.build(number: i, page_size: page_sizes[i - 1])
      end
    end
  end
  book.save!

  [
    { frame_size: FrameSize.find_by_name('size1'), text: 'frame1', color: '#ff0000', page: book.pages.first, x: 1, y: 1 },
    { frame_size: FrameSize.find_by_name('size2'), text: 'frame2', color: '#00ff00', page: book.pages.first, x: 3, y: 3 },
    { frame_size: FrameSize.find_by_name('size3'), text: 'frame3', color: '#0000ff', page: book.pages.second, x: 1, y: 1 },
    { frame_size: FrameSize.find_by_name('size4'), text: 'frame4', color: '#ff0000', page: book.pages.second, x: 0, y: 3 },
    { frame_size: FrameSize.find_by_name('size5'), text: 'frame5', color: '#00ff00' },
    { frame_size: FrameSize.find_by_name('size6'), text: 'frame6', color: '#0000ff' },
    { frame_size: FrameSize.find_by_name('size7'), text: 'frame7', color: '#ff0000' },
    { frame_size: FrameSize.find_by_name('size8'), text: 'frame8', color: '#00ff00' },
  ].each do |attrs|
    book.frames.build(**attrs)
  end
  book.save!

  book = Book.new(title: 'title2', description: 'description2')
  [
    { position: 1, page_count: 2, page_offset: 0 },
    { position: 2, page_count: 3, page_offset: 2 },
    { position: 3, page_count: 4, page_offset: 5 },
  ].each do |attrs|
    book.chapters.build(**attrs).tap do |chapter|
      1.upto(attrs[:page_count]) do |i|
        chapter.pages.build(number: i, page_size: page_sizes[0])
      end
    end
  end
  book.save!

  [
    { frame_size: FrameSize.find_by_name('size8'), text: 'frame1', color: '#ff0000' },
    { frame_size: FrameSize.find_by_name('size7'), text: 'frame2', color: '#00ff00' },
    { frame_size: FrameSize.find_by_name('size6'), text: 'frame3', color: '#0000ff' },
    { frame_size: FrameSize.find_by_name('size5'), text: 'frame4', color: '#ff0000' },
    { frame_size: FrameSize.find_by_name('size4'), text: 'frame5', color: '#00ff00' },
    { frame_size: FrameSize.find_by_name('size3'), text: 'frame6', color: '#0000ff' },
    { frame_size: FrameSize.find_by_name('size2'), text: 'frame7', color: '#ff0000' },
    { frame_size: FrameSize.find_by_name('size1'), text: 'frame8', color: '#00ff00' },
  ].each do |attrs|
    book.frames.build(**attrs)
  end
  book.save!
end
