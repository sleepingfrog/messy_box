class ElasticDeleteDocJob < ApplicationJob
  queue_as :default

  def perform(model)
    model.__elasticsearch__.delete_document
  end
end
