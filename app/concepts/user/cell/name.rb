# frozen_string_literal: true
module User::Cell
  class Name < Trailblazer::Cell
    property :name

    def show
      render
    end
  end
end
