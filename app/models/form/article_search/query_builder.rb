module Form
  class ArticleSearch
    class QueryBuilder
      def self.call(conditions)
        new(conditions).call
      end

      attr_reader :conditions
      def initialize(conditions)
        @conditions = HashWithIndifferentAccess.new(conditions)
      end

      def call
        queyr = if query_values.size > 1
          {
            bool: {
              must: query_values,
            },
          }
        elsif query_values.size == 1
          query_values.first
        else
          {
            match_all: {},
          }
        end
      end

      def query_values
        [query, tags].compact
      end

      def query
        if conditions[:query].present?
          {
            multi_match: {
              fields: ['title', 'body'],
              type: 'cross_fields',
              operator: 'and',
              query: conditions[:query],
            },
          }
        end
      end

      def tags
        tags_value = conditions[:tags].map(&:presence).compact
        if tags_value.present?
          {
            terms: {
              "tags.name": tags_value,
            },
          }
        end
      end
    end
  end
end
