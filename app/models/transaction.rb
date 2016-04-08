class Transaction < ActiveRecord::Base
  include PgSearch
  pg_search_scope :search,
                  against: :reported_description

end
