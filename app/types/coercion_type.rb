class CoercionType < ActiveModel::Type::Value
  attr_reader :choices
  def initialize(choices:, **options)
    super(**options)
    @choices = Array(choices)
  end

  def cast(value)
    v = super(value)
    if choices.include?(v)
      v
    end
  end
end
