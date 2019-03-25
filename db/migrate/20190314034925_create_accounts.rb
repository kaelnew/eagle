class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.integer :user_id, index: true
      t.string :title
      t.string :login
      t.string :encrypted_password
      t.string :url
      t.string :note
      t.integer :use_status, default: 0, index: true
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
