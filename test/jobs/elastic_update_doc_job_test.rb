# frozen_string_literal: true
require "test_helper"

class ElasticUpdateDocJobTest < ActiveJob::TestCase
  setup do
    Article.create!
  end

  test 'enqueued when article update' do
    article = Article.first
    assert_enqueued_jobs(1, only: ElasticUpdateDocJob) do
      article.title = 'updated'
      article.save!
    end
  end

  test 'not enqueued when article create' do
    assert_no_enqueued_jobs(only: ElasticUpdateDocJob) do
      Article.create!
    end
  end

  test 'not enqueued when article destroy' do
    article = Article.first
    assert_no_enqueued_jobs(only: ElasticUpdateDocJob) do
      article.destroy!
    end
  end
end
