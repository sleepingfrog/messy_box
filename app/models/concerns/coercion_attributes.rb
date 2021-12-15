module CoercionAttributes
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Attributes
  end

  class_methods do
    def coersion_attr(name, choices, **options)
      attribute(name, CoercionType.new(choices: choices), **options)
    end
  end
end
