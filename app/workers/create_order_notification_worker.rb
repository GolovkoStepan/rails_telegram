# frozen_string_literal: true

class CreateOrderNotificationWorker
  include Sidekiq::Worker

  def perform(*args)
    logger.info 'CreateOrderNotificationWorker task started'

    if (order = Order.find_by(id: args.first))
      TelegramUser.all.each do |user|
        TelegramWebhooksController.send_message(
          action: :new_order_notification,
          to: user.external_id,
          args: [order.id]
        )
      rescue Telegram::Bot::Forbidden
        logger.info "Bot is blocked by user with id =  #{user.external_id}"
        next
      end
    else
      logger.info "Order with id = #{args.first} not found"
    end

    logger.info 'CreateOrderNotificationWorker task finished'
  end
end
