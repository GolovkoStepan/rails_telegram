# frozen_string_literal: true

class TelegramUser < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
end
