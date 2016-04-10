# TODO - Should implement an "uncategorized" scope (i.e., no Categories associated).
class BankTransaction < ActiveRecord::Base
  belongs_to :card

  include PgSearch
  pg_search_scope :search,
                  against: :reported_description

end
