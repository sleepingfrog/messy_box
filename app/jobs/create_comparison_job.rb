class CreateComparisonJob < ApplicationJob
  queue_as :default

  def perform(before, after)
    ActiveRecord::Base.transaction do
      c = before.build_comparison_with_after(after: after)
      image, diff = compare_image(before, after)
      c.image.attach(io: StringIO.new(image.to_blob), filename: 'compare.png')
      c.diff = diff
      c.save!
    end
  end

  private

  def compare_image(before, after)
    image1, image2 = [before, after].map do |history|
      Magick::Image.from_blob(history.image.blob.download).first
    end

    image1.compare_channel(image2, Magick::MeanSquaredErrorMetric)
  end
end
