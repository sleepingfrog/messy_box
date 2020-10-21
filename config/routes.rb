# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users
  root 'home#index'

  get 'view_component_sample/index'
end
