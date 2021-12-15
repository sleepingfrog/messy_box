module MarginaliaOperationName
  def self.included(base_class)
    base_class.class_eval do
      around_action CallBacks.new
    end
  end

  class CallBacks
    def around(controller)
      operation_name = controller.params[:operationName]
      Marginalia::Comment.record_graphql_operation_name!(operation_name)
      yield
    ensure
      Marginalia::Comment.clear_graphql_operation_name!
    end
  end
end
