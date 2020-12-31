# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  extend Telegram::Bot::ConfigMethods

  ACTION_HANDLERS = {
    all_orders: 'Показать свободные заказы',
    user_orders: 'Показать заказы, назначенные мне'
  }.freeze

  def self.send_message(action:, to:, args:)
    new(bot, { from: { 'id' => to }, chat: { 'id' => to } }).process(action, args)
  end

  def new_order_notification(args)
    buttons = [[{ text: "Заказ №#{args.first}", callback_data: "detail_order##{args.first}" }]]
    respond_with :message, text: 'Поступил новый заказ!', reply_markup: { inline_keyboard: buttons }
  end

  def start!(*)
    return if from['is_bot']

    find_or_create_user!

    buttons = [[ACTION_HANDLERS[:all_orders]], [ACTION_HANDLERS[:user_orders]]]
    respond_with :message, text: 'Выберите действие:',
                           reply_markup: { keyboard: buttons, resize_keyboard: true, selective: true }
  end

  def message(msg)
    action = ACTION_HANDLERS.key(msg['text'])
    send(action) if action
  end

  def all_orders
    buttons = Order.free.map { |order| [{ text: "Заказ № #{order.id}", callback_data: "detail_order##{order.id}" }] }
    return respond_with :message, text: 'Доступных заказов нет.' if buttons.empty?

    respond_with :message, text: 'Список всех заказов в базе данных:', reply_markup: { inline_keyboard: buttons }
  end

  def user_orders
    user = TelegramUser.find_by(external_id: from['id'])
    return respond_with :message, text: 'Вы не зарегестрированы!' unless user

    buttons = Order.where(telegram_user: user).map do |order|
      [{ text: "Заказ №#{order.id}", callback_data: "detail_order##{order.id}" }]
    end

    return respond_with :message, text: 'У вас нет заказов.' if buttons.empty?

    respond_with :message, text: 'Список заказов, назначенных вам:', reply_markup: { inline_keyboard: buttons }
  end

  def callback_query(data)
    action, *args = parse_callback_query data
    send(action, args)
  end

  def detail_order(args)
    user = TelegramUser.find_by(external_id: from['id'])
    return respond_with :message, text: 'Вы не зарегестрированы!' unless user

    order = Order.find_by(id: args.first)
    return respond_with :message, text: "Заказ с номером #{args.first} не найден." unless order

    text = [
      "Заказ №#{order.id}",
      "Клиент: #{order.customer}",
      "Адрес: #{order.address}"
    ]

    buttons = []
    buttons << [{ text: 'Взять этот заказ', callback_data: "take_order##{order.id}" }] if order.telegram_user.nil?
    buttons << [{ text: 'Завершить этот заказ', callback_data: "complete_order##{order.id}" }] if order.telegram_user == user

    respond_with :message, text: text.join("\n"), reply_markup: { inline_keyboard: buttons }
  end

  def take_order(args)
    user = TelegramUser.find_by(external_id: from['id'])
    return respond_with :message, text: 'Вы не зарегестрированы!' unless user

    order = Order.free.find_by(id: args.first)
    return respond_with :message, text: "Заказ с номером #{args.first} не найден!" unless order

    user.orders << order
    respond_with :message, text: "Заказ номер #{args.first} назначен вам."
  end

  def complete_order(args)
    user = TelegramUser.find_by(external_id: from['id'])
    return respond_with :message, text: 'Вы не зарегестрированы!' unless user

    order = user.orders.find_by(id: args.first)
    return respond_with :message, text: "Заказ с номером #{args.first} не найден!" unless order

    order.destroy
    respond_with :message, text: "Заказ с номером #{args.first} завершен!"
  end

  private

  def find_or_create_user!
    TelegramUser.find_by(external_id: from['id']) || create_user!
  end

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

  def parse_callback_query(callback_str)
    callback_str.split('#')
  end
end
