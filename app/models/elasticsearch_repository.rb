class ElasticsearchRepository
  attr_reader :model, :query
  attr_accessor :size, :from

  def initialize(model, query = nil)
    @model = model
    @from = 0
    @query = query
  end

  def each(&block)
    array.each(&block)
  end

  def es_result
    @es_result ||= fetch
  end

  def fetch
    model.__elasticsearch__.search(build_request)
  end

  def array
    @array ||= es_result.records.to_a
  end

  def total_count
    es_result.response.dig('hits', 'total', 'value')
  end

  private

    def build_request
      if query.blank?
        request = {
          query: {
            match_all: {}
          }
        }
      else
        request = {
          query: query
        }
      end

      if size
        request = request.merge({ size: size })
      end

      if from
        request = request.merge({ from: from })
      end

      request
    end
end
