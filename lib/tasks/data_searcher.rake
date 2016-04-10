require 'csv'
require 'set'
require 'benchmark'

##
namespace :data_searcher do
  # => rake data_searcher:categorize_by_regexp_rules
  # TODO - Replace hash counter with adding new Category record to DB
  # TODO - Associate found Transactions with matching Category object
  desc "Search for potential categories from keywords"
  task categorize_by_regexp_rules: :environment do
    keyword_categories = {}
    queries = {
      "RECURRING" => /\b..... ([a-zA-Z|\s|*]{4,}+)/,
      "PURCHASE" => /\b..... ([a-zA-Z|\s|*]{4,}+)/
    }

    categories = {}
    no_match = []

    queries.each do |keyword, trxn_regexp|
      Transaction.search(keyword).each do |transaction|
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
        else
          no_match << transaction
        end
      end
    end

    puts "RESULTS:"
    total_match_count = 0
    categories.each do |k,v|
      total_match_count += v
      puts "\t#{k}\t~>\t#{v}"
    end

    puts "\r\nTOTAL CATEGORIES:\t#{categories.count}"
    puts "TOTAL MATCHED:\t#{total_match_count}"
    puts "TOTAL W/O MATCH:\t#{no_match.count}"
    no_match.each do |trxn|
      puts "[#{trxn.id}]\t#{trxn.reported_description}"
    end
  end

  desc "Search for potential categories from keywords"
  task categorize_by_search_terms: :environment do
    # TODO - Implement this after the Category model has been added to schema
    ## Start with ALL Transactions WITHOUT a Category
    # => Transaction.where("categories_transactions_ids = []")
    ## Manually hande:
    # => TODO - Handle `WF Direct Pay-Payment`
    # => TODO - Handle `CHECK`
    # => TODO - Handle `BILL PAY`
    # => TODO - Handle `SRP SUREPAY`
    # => TODO - Handle `Broadstone Water Rent`
    # => TODO - Handle `DIRECT PAY`
    # => TODO - Handle `INTERNATIONAL PURCHASE TRANSACTION FEE`
    # => TODO - Handle `POS PURCHASE`
  end
end

