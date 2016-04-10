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
end
