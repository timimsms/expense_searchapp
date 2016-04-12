# TODO - Add PgSeach; search method should be multi-search over
#        transaction_keyword and label
# TODO - Label should be used as an override when a label needs
#        to be manually applied over the raw transaction_keyword
#        found in the data
# TODO - The Category transaction_keyword attribute should be migrated to a
#        JSON hash or separate tableto allow support for multiple keywords.
#        May also want to link to support BankTransaction <-> Keywords.
class Category < ActiveRecord::Base
  has_and_belongs_to_many :bank_transactions,
                          join_table: :bank_transactions_categories

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

  def trxn_dates
    result = []
    bank_transactions.each do |trxn|
      result << trxn.reported_date
    end
    result
  end

  # TODO - move to an observer
  def pretty_trxn_dates(delim = ', ')
    trxn_dates.join(delim)
  end

  def trxn_date_range
    dates = []
    bank_transactions.each do |trxn|
      dates << Date.strptime(trxn.reported_date, "%m/%d/%y")
    end
    dates.sort! { |a,b| a <=> b }
    result = [dates.first, dates.last]
  end

  # TODO - move to an observer
  def pretty_trxn_date_range
    start_date, end_date = trxn_date_range
    "#{start_date.strftime("%m/%d/%y")} - #{end_date.strftime("%m/%d/%y")}"
  rescue
    "N/A"
  end

  # Last four CC #'s for BankTransactions - TW
  def trxn_card_digits
    result = Set.new
    bank_transactions.each do |trxn|
      if trxn.card.present?
        result.add(trxn.card.last_four_digits)
      end
    end
    result.to_a
  end

  # TODO - move to an observer
  def pretty_trxn_card_digits(delim = ', ')
    trxn_card_digits.join(delim)
  end

  # Gets around scope limitations of HABTM - TW
  # TODO - refactor as a single scope; likely by removing HABTM
  def self.by_transaction_count
    categories = Category.all.to_a
    categories.sort! { |a,b| b.trxn_count <=> a.trxn_count }
    categories
    categories.collect { |c| Category.find_by_id(c.id) }
  end
end
