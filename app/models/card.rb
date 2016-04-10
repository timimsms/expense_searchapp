class Card < ActiveRecord::Base
  has_many :bank_transactions
end
