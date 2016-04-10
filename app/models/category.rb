class Category < ActiveRecord::Base
  has_and_belongs_to_many :bank_transactions,
                          join_table: :bank_transactions_categories
end
