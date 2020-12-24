class CreateTelegramUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :telegram_users do |t|
      t.bigint :external_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :username, null: false
      t.string :language_code

      t.timestamps
    end

    add_index :telegram_users, :external_id, unique: true
  end
end
