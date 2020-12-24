# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  def start!(*)
    respond_with :message, text: 'OK'
  end
end
