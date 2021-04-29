module Form
  class ArticleSearch
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :query, :string
    attribute :tags, :string_array, default: []
    attribute :limit, :integer, default: 10

    def conditions
      attributes
    end

    def result
      converted_qeury = QueryBuilder.call(conditions)
      Article.__elasticsearch__.search(query: converted_qeury, size: limit)
    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, Form)
    end
  end
end