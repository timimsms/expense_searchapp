require 'csv'
require 'set'
require 'benchmark'

##
#
namespace :data_searcher do
  desc "Search for potential categories"
  task category_search: :environment do
    categories = {}
    Transaction.search("RECURRING").each do |transaction|
      trxn_regexp = /RECURRING PAYMENT AUTHORIZED ON ..... (.+) ...-.../
      match = transaction.reported_description.match trxn_regexp

      if match.present?
        result_category = match[1]

        if result_category.present?
          if categories[result_category].blank?
            categories[result_category] = 1
          else
            categories[result_category] += 1
          end
        end

        puts "Resulting Categories:"
        categories.each do |k,v|
          puts "#{k}\t~>\t#{v}"
        end
        puts "\t\tTotal Categories:\t#{categories.count}"
      else
        puts "NO MATCH: #{transaction.reported_description}"
      end
    end
  end
end

