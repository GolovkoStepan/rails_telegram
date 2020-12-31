class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :customer
      t.string :address
      t.belongs_to :telegram_user, foreign_key: true

      t.timestamps
    end
  end
end
