class AddCardRefToTransactions < ActiveRecord::Migration
  def change
    add_reference :transactions, :card, index: true, foreign_key: true
  end
end
