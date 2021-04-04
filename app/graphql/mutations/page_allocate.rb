module Mutations
  class PageAllocate < BaseMutation

    class PageAllocationFrameType < Types::BaseInputObject
      argument :id, ID, required: true
      argument :x, Integer, required: true
      argument :y, Integer, required: true
    end

    argument :page_id, ID, required: true
    argument :frames, [PageAllocationFrameType], required: true

    field :status, String, null: false
    field :frames, [Types::FrameType], null: true

    def resolve(page_id:, frames:)
      # need some validation
      page = nil
      Page.transaction do
        page = Page.find(page_id)

        new_frames = []
        frames.each do |frame_param|
          frame = Frame.find(frame_param[:id])
          frame.x = frame_param[:x]
          frame.y = frame_param[:y]
          new_frames << frame
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
