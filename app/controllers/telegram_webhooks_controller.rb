# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  use_session!

  def self.send_message(to:, text:)
    new(bot, { from: { 'id' => to }, chat: { 'id' => to } }).process(:send_message, text)
  end

  def send_message(text)
    respond_with :message, text: text
  end

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

  def keyboard!(*words)
    buttons = [
      ['Кнопка 1', 'Кнопка 2', 'Кнопка 3'],
      ['Кнопка 4', 'Кнопка 5', 'Кнопка 6'],
      ['Кнопка 7', 'Кнопка 8', 'Кнопка 9']
    ]

    if words.any?
      respond_with :message, text: "Вы выбрали: #{words.join(' ')}"
    else
      save_context :keyboard!
      respond_with :message, text: 'Выберите действие:', reply_markup: {
        keyboard: buttons,
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
    end
  end

  def inline_keyboard!(*)
    respond_with :message, text: 'Что вы выберите?', reply_markup: {
      inline_keyboard: [
        [
          { text: 'Показать алерт', callback_data: 'alert' },
          { text: 'Не показывать алерт', callback_data: 'no_alert' }
        ]
      ]
    }
  end

  def callback_query(data)
    if data == 'alert'
      answer_callback_query 'Вот алерт!'
    else
      respond_with :message, text: 'Не будет алерта...'
    end
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
