class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :last_four_digits
      t.string :owner

      t.timestamps null: false
    end
    add_index :cards, :last_four_digits, :unique => true
  end
end
