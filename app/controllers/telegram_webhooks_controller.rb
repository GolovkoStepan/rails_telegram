# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  def start!(*)
    return if from['is_bot']

    if TelegramUser.find_by(external_id: from['id'])
      respond_with :message, text: 'Привет!'
    else
      respond_with :message, text: 'Привет! Вы зарегистрированы!'
    end
  end

  private

  def create_user!
    TelegramUser.create!(
      external_id: from['id'],
      first_name: from['first_name'],
      last_name: from['last_name'],
      username: from['username'],
      language_code: from['language_code']
    )
  end
end
