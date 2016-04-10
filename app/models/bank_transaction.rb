# TODO - Should implement an "uncategorized" scope (i.e., no Categories associated).
class BankTransaction < ActiveRecord::Base
  belongs_to :card
  has_and_belongs_to_many :categories,
                          join_table: :bank_transactions_categories

  include PgSearch
  pg_search_scope :search,
                  against: :reported_description

  scope :uncategorized, -> {
    where(<<-SQL)
          NOT EXISTS (SELECT 1
            FROM   bank_transactions_categories
            WHERE  bank_transactions.id = bank_transactions_categories.bank_transaction_id)
        SQL
  }
end
