# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

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

  def pick!(*)
    save_context :pick_action
    respond_with :message, text: "Выберите действие:\n1) Действие 1\n2) Действие 2"
  end

  def pick_action(action = nil, *)
    respond_with :message, text: "Вы выбрали действие #{action}"
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
