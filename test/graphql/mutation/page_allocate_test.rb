require 'test_helper'

class GraphqlMutationPageAllocateTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)

    current_time = Time.current
    [
      { name: 'size1', width: 1, height: 1 },
      { name: 'size2', width: 2, height: 2 },
    ].each do |attr|
      FrameSize.create!(**attr)
    end
    PageSize.create!(name: 'psize1', width: 3, height: 2)

    @book = Book.new(title: 'title', description: "description")
    [
      { position: 1, page_count: 1, page_offset: 0 },
    ].each do |attrs|
      @book.chapters.build(**attrs).tap do |chapter|
        1.upto(attrs[:page_count]) do |i|
          chapter.pages.build(number: i, page_size: PageSize.find_by_name('psize1'))
        end
      end
    end

    [
      { frame_size: FrameSize.find_by_name('size1'), text: 'frame1', color: '#00ff00' },
      { frame_size: FrameSize.find_by_name('size1'), text: 'frame2', color: '#0000ff' },
      { frame_size: FrameSize.find_by_name('size2'), text: 'frame3', color: '#ff0000' },
      { frame_size: FrameSize.find_by_name('size2'), text: 'frame4', color: '#00ff00' },
    ].each do |attrs|
      @book.frames.build(**attrs)
    end
    @book.save!

    @mutation = <<~MUT
      mutation pageAllocate($input: PageAllocateInput!){
        pageAllocate(input: $input){
          status
        }
      }
    MUT
  end

  test 'valid variables' do
    @page = @book.pages.first
    variables = {
      input: {
        bookId: @page.chapter.book.id,
        chapterPosition: @page.chapter.position,
        pageNumber: @page.number,
        frames: [
          { x: 0, y: 0, id: Frame.find_by_text('frame1').id }
        ],
      }
    }
    result = nil

    assert_difference('Page.find(@page.id).frames.count', 1) do
      result = MessyBoxSchema.execute(@mutation, context: { current_user: User.find(@user.id) }, variables: variables)
    end

    assert_nil result.dig('errors')
    assert_equal 'succeeded', result.dig('data', 'pageAllocate', 'status')
  end

  test 'frame collision' do
    @page = @book.pages.first
    variables = {
      input: {
        bookId: @page.chapter.book.id,
        chapterPosition: @page.chapter.position,
        pageNumber: @page.number,
        frames: [
          { x: 0, y: 0, id: Frame.find_by_text('frame1').id },
          { x: 0, y: 0, id: Frame.find_by_text('frame2').id },
        ],
      }
    }
    result = nil

    assert_no_difference('Page.find(@page.id).frames.count') do
      result = MessyBoxSchema.execute(@mutation, context: { current_user: User.find(@user.id) }, variables: variables)
    end
    assert_nil result.dig('errors')
    assert_equal 'failed', result.dig('data', 'pageAllocate', 'status')
  end

  test 'frame overflow on height' do
    @page = @book.pages.first
    variables = {
      input: {
        bookId: @page.chapter.book.id,
        chapterPosition: @page.chapter.position,
        pageNumber: @page.number,
        frames: [
          { x: 0, y: 1, id: Frame.find_by_text('frame3').id },
        ],
      }
    }
    result = nil

    assert_no_difference('Page.find(@page.id).frames.count') do
      result = MessyBoxSchema.execute(@mutation, context: { current_user: User.find(@user.id) }, variables: variables)
    end
    assert_nil result.dig('errors')
    assert_equal 'failed', result.dig('data', 'pageAllocate', 'status')
  end

  test 'frame overflow on width' do
    @page = @book.pages.first
    variables = {
      input: {
        bookId: @page.chapter.book.id,
        chapterPosition: @page.chapter.position,
        pageNumber: @page.number,
        frames: [
          { x: 2, y: 0, id: Frame.find_by_text('frame3').id },
        ],
      }
    }
    result = nil

    assert_no_difference('Page.find(@page.id).frames.count') do
      result = MessyBoxSchema.execute(@mutation, context: { current_user: User.find(@user.id) }, variables: variables)
    end
    assert_nil result.dig('errors')
    assert_equal 'failed', result.dig('data', 'pageAllocate', 'status')
  end
end
