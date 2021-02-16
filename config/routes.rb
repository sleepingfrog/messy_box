# frozen_string_literal: true
Rails.application.routes.draw do
  namespace :users do
    resources :todos, only: [:index]
  end

  resources :articles, only: [:index]

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  devise_for :users
  root 'home#index'

  get 'view_component_sample/index'

  namespace :konva_sample do
    root action: :index
  end

  resources :books, only: [:index]
end
