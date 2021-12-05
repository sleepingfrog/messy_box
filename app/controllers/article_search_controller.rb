class ArticleSearchController < ApplicationController
  def index
    @search_form = Form::ArticleSearch.new(search_params)
    @result = @search_form.result
    @articles = @result.records.preload(:tags)
  end

  private

    def search_params
      params.fetch(:article_search, {}).permit(:query, :page, :size, tags: [])
    end
end
