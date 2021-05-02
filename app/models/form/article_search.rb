module Form
  class ArticleSearch
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :query, :string
    attribute :tags, :string_array, default: []
    attribute :size, :integer, default: 10
    attribute :page, :integer, default: 1

    def conditions
      attributes.slice('query', 'tags')
    end

    def result
      converted_qeury = QueryBuilder.call(conditions)
      Article.__elasticsearch__.search(query: converted_qeury, size: size, from: from)
    end

    def self.model_name
      @_model_name ||= ActiveModel::Name.new(self, Form)
    end

    def from
      size * (page - 1)
    end
  end
end