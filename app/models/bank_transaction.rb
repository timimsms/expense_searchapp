require 'csv'

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

  def category_keywords
    self.categories.map(&:transaction_keyword)
  end

  ## CSV Export
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << csv_column_names
      all.each do |bank_transaction|
        csv << bank_transaction.csv_column_values
      end
    end
  end

  def self.csv_column_names
    [
      'ID', 'Reported Date', 'Reported Amount',
      'Reported Description', 'Category', 'Card'
    ]
  end

  def csv_column_values
    [
      self.id, self.reported_date, self.reported_amount,
      self.reported_description, self.category_keywords.join("; "),
      (self.card.last_four_digits if self.card.present?)
    ]
  end
end
