class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :reported_date
      t.string :reported_amount
      t.string :reported_description
      t.boolean :is_complete

      t.timestamps null: false
    end
  end
end
