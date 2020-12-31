# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'documentation#index'

  telegram_webhook TelegramWebhooksController

  namespace :api do
    resources :orders, only: :create
  end
end
