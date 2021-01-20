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
    fetch.response.dig('hits', 'total', 'value')
  end

  def facets
    fetch.response.dig('aggregations', 'tags', 'buckets').each_with_object([]).map do |bucket|
      {
        key: bucket['key'],
        count: bucket['doc_count']
      }
    end
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

      request = request.merge({
        aggs: {
          tags: {
            terms: {
              field: 'tags.name',
              size: 10,
            },
          }
        }
      })

      request
    end
end
