class AddSubjectToMoneyRecords < ActiveRecord::Migration[5.2]
  def change
    add_column :money_records, :subject, :integer, default: 0, index: true
    add_column :money_records, :personal_share, :decimal, precision: 10, scale: 2, default: 0
  end
end
