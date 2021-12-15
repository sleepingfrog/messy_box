# frozen_string_literal: true
require "test_helper"

class ElasticIndexDocJobTest < ActiveJob::TestCase
  setup do
    Article.create!
  end

  test 'enqueue when article create' do
    assert_enqueued_jobs(1, only: ElasticIndexDocJob) do
      Article.create!
    end
  end

  test 'not enqueued when article update' do
    article = Article.first
    assert_no_enqueued_jobs(only: ElasticIndexDocJob) do
      article.title = 'updated'
      article.save!
    end
  end

  test 'not enqueued when article destroy' do
    article = Article.first
    assert_no_enqueued_jobs(only: ElasticIndexDocJob) do
      article.destroy!
    end
  end
end
