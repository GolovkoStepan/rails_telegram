# frozen_string_literal: true

class TelegramUser < ApplicationRecord
  has_many :orders, dependent: :nullify
  validates :external_id, presence: true, uniqueness: true
end
