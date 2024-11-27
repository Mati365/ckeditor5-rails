# frozen_string_literal: true

Sandbox::Application.routes.draw do
  root 'demos#index'

  resources :demos, only: [], path: '/' do
    collection do
      %i[
        classic classic_controller_preset decoupled
        form multiroot context balloon inline
        locale_via_assets locale_via_editor locale_via_preset locale_via_rails_i18n
      ].each do |action|
        get action
      end
    end
  end
end
