class Card < ActiveRecord::Base
  has_many :bank_transactions

  def trxn_count
    self.bank_transactions.count
  end

  def trxn_total
    total = 0
    bank_transactions.each do |trxn|
      total += trxn.reported_amount.to_f
    end
    total
  end
end
