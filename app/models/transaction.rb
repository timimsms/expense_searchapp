class Transaction < ActiveRecord::Base
  belongs_to :card

  include PgSearch
  pg_search_scope :search,
                  against: :reported_description

end
