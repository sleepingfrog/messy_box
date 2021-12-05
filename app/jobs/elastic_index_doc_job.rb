# frozen_string_literal: true
class ElasticIndexDocJob < ApplicationJob
  queue_as :default

  def perform(model)
    model.__elasticsearch__.index_document
  end
end
