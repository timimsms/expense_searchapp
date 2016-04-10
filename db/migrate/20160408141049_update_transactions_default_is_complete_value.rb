class UpdateTransactionsDefaultIsCompleteValue < ActiveRecord::Migration
  def up
    change_column :transactions, :is_complete, :boolean, default: false
  end
end
