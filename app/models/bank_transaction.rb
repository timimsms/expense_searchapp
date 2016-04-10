# TODO - Should implement an "uncategorized" scope (i.e., no Categories associated).
class BankTransaction < ActiveRecord::Base
  belongs_to :card
  has_and_belongs_to_many :categories,
                          join_table: :bank_transactions_categories

  include PgSearch
  pg_search_scope :search,
                  against: :reported_description

end
