# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :telegram_user, optional: true
  validates :customer, :address, presence: true

  scope :free, -> { where(telegram_user_id: nil) }

  after_create :notify_telegram_users

  def notify_telegram_users
    msg = "Поступил новый заказ №#{id}"

    TelegramUser.all.each do |user|
      TelegramWebhooksController.send_message(to: user.external_id, text: msg)
    end
  end
end
