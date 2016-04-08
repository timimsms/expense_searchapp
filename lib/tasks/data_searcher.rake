require 'csv'
require 'set'
require 'benchmark'

##
#
# TODO - add ability to pass / set file param(s)
namespace :data_searcher do
  # desc "TODO"
  task test_search: :environment do
    Transaction.find_each(batch_size: 500).with_index.each do |trxn, i|

    end
  end
end

