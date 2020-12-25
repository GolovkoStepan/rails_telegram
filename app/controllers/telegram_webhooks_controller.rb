# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  use_session!

  def start!(*)
    return if from['is_bot']

    if TelegramUser.find_by(external_id: from['id'])
      respond_with :message, text: 'Привет!'
    else
      create_user!
      respond_with :message, text: 'Привет! Вы зарегистрированы!'
    end
  end

  def save!(*words)
    session[:msg] = words.join(' ')
    respond_with :message, text: 'Ваше сообщение сохранено!'
  end

  def load!(*)
    respond_with :message, text: "Ваше сохраненное сообщение: #{session[:msg]}"
  end

  private

  def session_key
    "#{bot.username}:#{chat['id']}:#{from['id']}" if chat && from
  end

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
