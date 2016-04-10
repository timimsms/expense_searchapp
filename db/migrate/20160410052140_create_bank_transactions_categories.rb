class CreateBankTransactionsCategories < ActiveRecord::Migration
  def change
    create_table :bank_transactions_categories, id: false do |t|
      t.integer :bank_transaction_id, null: false
      t.integer :category_id, null: false
    end
  end
end
