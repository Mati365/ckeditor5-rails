# frozen_string_literal: true

Sandbox::Application.routes.draw do
  root 'demos#index'

  resources :demos, only: [], path: '/' do
    collection do
      get :classic
      get :classic_controller_preset
      get :decoupled
      get :form
      get :multiroot
      get :context
    end
  end
end
