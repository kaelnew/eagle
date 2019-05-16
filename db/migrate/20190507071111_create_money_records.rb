class CreateMoneyRecords < ActiveRecord::Migration[5.2]
  def change
    create_table :money_records do |t|
      t.bigint :user_id, index: true
      t.integer :income_flag, default: 0, index: true
      t.decimal :amount, precision: 10, scale: 2
      t.date :happened_at, index: true
      t.string :remark
      t.bigint :parent_id, index: true
      t.timestamps
    end
  end
end
