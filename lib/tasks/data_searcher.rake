require 'csv'
require 'set'
require 'benchmark'

##
# Note: The intent of this file is purely for experimental data searches and
# investigative development. Once a method begins to produce long-term results
# (e.g., saves changes to an object), the method should be moved to another
# Rake namespace / task file.
#
namespace :data_searcher do
  # => rake data_searcher:categorize_by_regexp_rules
  # TODO - Replace hash counter with adding new Category record to DB
  # TODO - Associate found BankTransactions with matching Category object
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
      BankTransaction.uncategorized.search(keyword).each do |bank_transaction|
        match = bank_transaction.reported_description.match trxn_regexp

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
          no_match << bank_transaction
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
    search_terms = [
      "WF Direct Pay-Payment",
      "CHECK",
      "BILL PAY",
      "SRP SUREPAY",
      "Broadstone Water Rent",
      "DIRECT PAY",
      "INTERNATIONAL PURCHASE TRANSACTION FEE",
      "POS PURCHASE"
    ]
    categories = {}

    total_categorized = 0
    search_terms.each do |search_term|
      categories[search_term] = BankTransaction.uncategorized.search(search_term).count
      total_categorized += categories[search_term]
    end

    puts "== == RESULTS == =="
    categories.each do |k,v|
      puts "#{k}:\t#{v}"
    end
    puts "\r\nTOTAL CATEGORIZED: #{total_categorized}"
    puts "REMAINING UNCATEGORIZED: #{BankTransaction.uncategorized.count}"
  end

  desc "Lists all remaining uncategorized BankTransactions"
  task list_uncategorized_transactions: :environment do
    BankTransaction.uncategorized.each do |bt|
      puts "[#{bt.id}]\t#{bt.reported_description}"
    end
    puts "\r\nTOTAL COUNT: #{BankTransaction.uncategorized.count}"
  end
end

