class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :transaction_keyword, unique: true
      t.string :label
      t.text :description

      t.timestamps null: false
    end
  end
end
