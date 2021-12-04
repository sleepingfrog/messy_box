# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do

  devise_for :users
  root 'home#index'

  post "/graphql", to: "graphql#execute"

  resources :articles, only: [:index]
  namespace 'article_search' do
    root action: :index
  end

  get 'async_notification/index'

  namespace :users do
    resources :todos, only: [:index]
  end

  get 'view_component_sample/index'

  namespace :konva_sample do
    root action: :index
  end

  resources :books, only: [:index] do
    member do
      get :show, path: '(/chapters/:position(/pages/:number))'
    end
  end

  resources :entries, only: %i[ index show new create ] do
    member do
      post 'create_history', action: :create_history
    end
  end
  resources :histories, only: %i[ show ]

  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
end
