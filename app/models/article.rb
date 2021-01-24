# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Article < ApplicationRecord
  include Elasticsearch::Model

  has_and_belongs_to_many :tags

  scope :with_tags, ->() { preload(:tags) }

  index_name "es_article_#{Rails.env}"

  settings do
    mappings dynamic: false do
      indexes :id, type: 'integer'
      indexes :title, type: 'text', analyzer: 'kuromoji'
      indexes :body, type: 'text', analyzer: 'kuromoji'
      indexes :tags do
        indexes :name, type: 'keyword'
      end
    end
  end

  def as_indexed_json(*)
    as_json(include: { tags: { only: :name } })
  end

  def self.create_index!
    client = __elasticsearch__.client
    client.indices.delete(index: self.index_name) rescue nil

    client.indices.create(
      index: self.index_name,
      body: {
        settings: self.settings.to_hash,
        mappings: self.mappings.to_hash,
      }
    )
  end
end
