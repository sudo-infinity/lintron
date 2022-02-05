class CreateUserTokens < ActiveRecord::Migration
  def change
    create_table :user_tokens do |t|
      t.belongs_to :user
      t.string :token, index: true
      t.timestamps null: false
    end
  end
end
