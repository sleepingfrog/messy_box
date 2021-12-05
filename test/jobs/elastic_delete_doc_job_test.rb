# frozen_string_literal: true
require "test_helper"

class ElasticDeleteDocJobTest < ActiveJob::TestCase
  setup do
    Article.create!
  end

  test 'enqueued when article destroy' do
    article = Article.first
    assert_enqueued_jobs(1, only: ElasticDeleteDocJob) do
      article.destroy!
    end
  end

  test 'not enqueue when article create' do
    assert_no_enqueued_jobs(only: ElasticDeleteDocJob) do
      Article.create!
    end
  end

  test 'not enqueued when article update' do
    article = Article.first
    assert_no_enqueued_jobs(only: ElasticDeleteDocJob) do
      article.title = 'updated'
      article.save!
    end
  end
end
