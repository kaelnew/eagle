class CreateUserAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_answers do |t|
      t.integer :user_id, index: true
      t.integer :question_id, index: true
      t.string :question_title
      t.string :encrypted_answer
      t.timestamps
    end
  end
end
