class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :avatar
      t.string :encrypted_password
      t.string :rsa_pub_key
      t.timestamp :rsa_pub_key_created_at
      t.integer :role, default: 0
      t.integer :delete_status, default: 0
      t.timestamp :deleted_at
      t.timestamps
    end
  end
end
