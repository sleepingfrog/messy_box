# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  namespace :users do
    resources :todos, only: [:index]
  end
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  devise_for :users
  root 'home#index'

  get 'view_component_sample/index'

  if Rails.env.development?
    mount Sidekiq::Web, at: '/sidekiq'
  end
end
