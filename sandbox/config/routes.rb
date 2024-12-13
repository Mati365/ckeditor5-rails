# frozen_string_literal: true

Sandbox::Application.routes.draw do
  root to: 'demos#index'

  scope '/', controller: 'demos' do
    %w[
      classic
      classic_controller_preset
      classic_wproofreader
      classic_lazy_assets
      classic_grouped_toolbar
      decoupled
      form
      form_ajax
      multiroot
      context
      balloon
      balloon_block
      inline
      locale_via_assets
      locale_via_editor
      locale_via_preset
      locale_via_rails_i18n
    ].each do |route|
      get route, as: "#{route}_demos"
    end

    post 'form_ajax', as: :form_ajax_post_demos
    post 'form_turbo_stream', as: :form_turbo_stream_demos
  end
end
