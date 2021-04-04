module Mutations
  class PageAllocate < BaseMutation

    class PageAllocationFrameType < Types::BaseInputObject
      argument :id, ID, required: true
      argument :x, Integer, required: true
      argument :y, Integer, required: true
    end

    argument :bookId, ID, required: true
    argument :chapterPosition, Integer, required: true
    argument :pageNumber, Integer, required: true
    argument :frames, [PageAllocationFrameType], required: true

    field :status, String, null: false
    field :frames, [Types::FrameType], null: true

    def resolve(bookId:, chapterPosition:, pageNumber:, frames:)
      # need some validation
      page = nil
      Page.transaction do
        page = Page.lock.joins(chapter: :book).find_by(number: pageNumber, chapters: { position: chapterPosition, books: {id: bookId} })

        new_frames = []
        frames.each do |frame_param|
          frame = Frame.find(frame_param[:id])
          frame.x = frame_param[:x]
          frame.y = frame_param[:y]
          new_frames << frame
        end

        if new_frames.any? { |frame| (page.page_size.width < frame.x + frame.frame_size.width) || (page.page_size.height < frame.y + frame.frame_size.height) }
          raise ActiveRecord::RecordNotSaved
        end

        if new_frames.combination(2).any? { |(frame, other)| (frame.x <= other.x + other.frame_size.width - 1) && (frame.y <= other.y + other.frame_size.height - 1) && ( other.x <= frame.x + frame.frame_size.width - 1) && (other.y <= frame.y + frame.frame_size.height - 1)  }
          raise ActiveRecord::RecordNotSaved
        end

        old_frames = page.frames
        old_frames.each do |frame|
          next if frame.id.in?(new_frames.map(&:id))
          frame.page_id = nil
          frame.x = nil
          frame.y = nil
          frame.save!
        end

        new_frames.each(&:save!)

        page.frames = new_frames
      end

      {
        status: 'succeeded',
        frames: page.frames,
      }
    rescue => e
      {
        status: 'failed'
      }
    end
  end
end
