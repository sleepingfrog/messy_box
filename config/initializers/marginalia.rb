# frozen_string_literal: true
require 'marginalia'

module Marginalia
  module Comment
    def self.graphql_operation
      Thread.current[:marginalia_graphql_operation]
    end

    def self.record_graphql_operation_name!(operation_name)
      self.graphql_operation = operation_name
    end

    def self.clear_graphql_operation_name!
      self.graphql_operation = nil
    end

    def self.graphql_operation=(operation_name)
      Thread.current[:marginalia_graphql_operation] = operation_name
    end
  end
end

Marginalia::Comment.components = %i(application controller_with_namespace action job graphql_operation)
