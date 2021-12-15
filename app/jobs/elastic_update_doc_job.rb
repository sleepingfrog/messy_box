# frozen_string_literal: true
class ElasticUpdateDocJob < ApplicationJob
  queue_as :default

  def perform(model)
    model.__elasticsearch__.update_document
  end
end
