class ElasticsearchRepository
  attr_reader :model
  attr_accessor :size, :from

  def initialize(model)
    @model = model
    @from = 0
  end

  def each(&block)
    array.each(&block)
  end

  def es_result
    @es_result ||= fetch
  end

  def fetch
    model.__elasticsearch__.search(build_query)
  end

  def array
    @array ||= es_result.records.to_a
  end

  def total_count
    es_result.response.dig('hits', 'total', 'value')
  end

  private

    def build_query
      query = {
        query: {
          match_all: {}
        }
      }

      if size
        query = query.merge({ size: size })
      end

      if from
        query = query.merge({ from: from })
      end
    end
end
