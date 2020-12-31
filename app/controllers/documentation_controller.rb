# frozen_string_literal: true

class DocumentationController < ApplicationController
  def index
    render plain: 'Telegram Bot Rails Application'
  end
end
