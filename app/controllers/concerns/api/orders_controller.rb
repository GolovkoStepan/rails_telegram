# frozen_string_literal: true

module Api
  class OrdersController < ApplicationController
    before_action :http_basic_authenticate

    def create
      order  = Order.create(customer: params[:customer], address: params[:address])
      result = order.save ? { status: :ok } : { errors: order.errors.messages }

      render json: result
    end

    private

    def http_basic_authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == ENV['API_BASIC_AUTH_USER'] && password == ENV['API_BASIC_AUTH_PASSWORD']
      end
    end
  end
end
