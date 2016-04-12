require 'csv'
require 'set'
require 'benchmark'

##
#
# TODO - add ability to pass / set file param(s)
namespace :data_importer do
  IMPORT_FILE_DIR  = "#{Rails.root}/src/"
  LOG_DIR = "#{Rails.root}/log/"

  desc "Imports bank bank_transactions from a specified file."
  task import_bank_transactions: :environment do
    # Setup
    log_datetime = DateTime.now.strftime("%Y%jT%H%M%S")
    err_log_file = "import-errors_#{log_datetime}.log"
    proc_log_file = "import-progress_#{log_datetime}.log"
    error_logger = Logger.new(File.open(LOG_DIR + err_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    proc_logger = Logger.new(File.open(LOG_DIR + proc_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    row_i = 0; bank_transaction_errors = 0; bank_transactions_added = 0

    # Import filename variable(s)
    import_filenames = Dir["#{IMPORT_FILE_DIR}*.csv"]

    # Main Import
    Benchmark.bm do |marker|
      marker.report("import_to_db") do
        import_filenames.each do |import_filepath|
          CSV.foreach(import_filepath) do |bank_transaction_row|
            row_i += 1
            new_trxn = BankTransaction.new({
              reported_date: bank_transaction_row[0],
              reported_amount: bank_transaction_row[1],
              reported_description: bank_transaction_row[4]
            })
            begin
              # proc_logger.info("[TEST-SAVE][#{row_i}]\t#{new_trxn.inspect}")
              new_trxn.save!
              bank_transactions_added += 1
            rescue Exception => e
              bank_transaction_errors += 1
              error_msg = "#{bank_transaction_row}\t[Error: #{e.inspect}]"
              error_logger.error("Error importing Row##{row_i}: #{error_msg}")
            end
          end
        end
      end
      puts "== == == RESULTS == == =="
      puts "BankTransactions Added:\t#{bank_transactions_added}"
      puts "Import Errors:\t\t#{bank_transaction_errors}"
    end
  end

  desc "Imports Card data from existing BankTransactions"
  task import_cards: :environment do
    card_regexp = /CARD\s(\d{4})/
    BankTransaction.search("CARD").each do |bank_transaction|
      match = bank_transaction.reported_description.match card_regexp

      if match.present?
        result_card_num = match[1]
        card = Card.where(last_four_digits: result_card_num).first
        if (result_card_num.present?) && !card.present?
          card = Card.new({
            last_four_digits: result_card_num
          })
          card.save!
        end
        bank_transaction.card = card
        bank_transaction.save!
      else
        puts "NO MATCH: #{bank_transaction.reported_description}"
      end
    end
  end

  desc "Import Category data from existing BankTranscations using Regex rules."
  task import_categories_via_regex: :environment do
    log_datetime = DateTime.now.strftime("%Y%jT%H%M%S")
    err_log_file = "category_regex-errors_#{log_datetime}.log"
    proc_log_file = "category_regex-progress_#{log_datetime}.log"
    no_match_log_file = "category_regex-unmatched_#{log_datetime}.log"
    error_logger = Logger.new(File.open(LOG_DIR + err_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    proc_logger = Logger.new(File.open(LOG_DIR + proc_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    queries = {
      "RECURRING" => /\b..... ([a-zA-Z|\s|*]{4,}+)/,
      "PURCHASE" => /\b..... ([a-zA-Z|\s|*]{4,}+)/
    }
    no_match = []; total_match_count = 0; new_cat_count = 0
    queries.each do |keyword, trxn_regexp|
      BankTransaction.uncategorized.search(keyword).each do |bank_transaction|
        match = bank_transaction.reported_description.match trxn_regexp
        if match.present?
          result_category = match[1]
          if result_category.present?
            total_match_count += 1
            category = Category.where(transaction_keyword: result_category).first
            if category.blank?
              begin
                category = Category.new({
                  transaction_keyword: result_category
                })
                category.save!
                new_cat_count += 1
                proc_logger.info("New Category created for `#{result_category}`!")
              rescue Exception => e
                error_logger.error(e)
                proc_logger.info("Category create! failed for `#{result_category}`.")
              end
            end

            if category.present? && category.valid?
              bank_transaction.categories << category
              bank_transaction.save!
              proc_logger.info("BankTransaction##{bank_transaction.id} := `#{result_category}`")
            end
          end
        else
          no_match << bank_transaction
          proc_logger.info("[#{bank_transaction.id}]\t#{bank_transaction.reported_description}")
        end
      end
    end
    proc_logger.info("")
    proc_logger.info("=" * 80)
    proc_logger.info("TOTAL CATEGORIES:\t#{Category.count} (#{new_cat_count} new!)")
    proc_logger.info("TOTAL CATEGORIZED:\t#{total_match_count}")
    proc_logger.info("TOTAL W/O CATEGORY:\t#{no_match.count}")
    proc_logger.info("(See #{no_match_log_file} for unmatched BankTransction information)")
  end

  desc "Import Category data from existing BankTranscations with manually defined rules."
  task import_categories_via_rules: :environment do
    log_datetime = DateTime.now.strftime("%Y%jT%H%M%S")
    err_log_file = "category_rules-errors_#{log_datetime}.log"
    proc_log_file = "category_rules-progress_#{log_datetime}.log"
    error_logger = Logger.new(File.open(LOG_DIR + err_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    proc_logger = Logger.new(File.open(LOG_DIR + proc_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))

    search_terms = [
      "WF Direct Pay-Payment",
      "CHECK",
      "BILL PAY",
      "SRP SUREPAY",
      "Broadstone Water Rent",
      "DIRECT PAY",
      "INTERNATIONAL PURCHASE TRANSACTION FEE",
      "POS PURCHASE",
      "DEBIT CARD",
      "Payroll Service PAYROLL",
      "ONLINE TRANSFER",
      "WIRE TRANS SVC CHARGE",
      "AMERICAS BUSINES PREAUTHPMT",
      "FEE",
      "THE HARTFORD NWTBCLSCIC",
      "Cottonwoods LLC Rent",
      "KABBAGE INC PAYMENT",
      "WT FED#",
      "ZENPAYROLL",
      "WITHDRAWAL",
      "RECUR DEBIT CRD",
      "GUSTO",
      "WT",
      "eDeposit",
      "KABBAGE INC LOAN",
      "eWithdrawal",
      "Little Cottonwoo Rent",
      "OVERDRAFT",
      "TRANSFER",
      "VERIZON WIRELESS",
      "BANKCARD",
      "COX",
      "DEBIT CRD",
      "AUTHNET GATEWAY BILLING",
      "AETNA",
      "HMF HMFUSA.com",
      "DEPOSIT",
      "PAYSIMPLE",
      "ONLINE DEP DETAIL & IMAGES",
      "PHILA INS CO",
      "WF Bus Credit",
      "THE GUARDIAN",
      "Dropbox*",
      "PAYPAL *",
      "ODESK"
    ]
    new_cat_count = 0; total_match_count = 0

    search_terms.each do |search_term|
      category = Category.where(transaction_keyword: search_term).first
      unless category.present?
        begin
          category = Category.new({
            transaction_keyword: search_term
          })
          category.save!
          new_cat_count += 1
          proc_logger.info("New Category created for `#{search_term}`!")
        rescue Exception => e
          error_logger.error(e)
          proc_logger.info("Category create! failed for `#{search_term}`.")
        end
      end

      if category.present? && category.valid?
        BankTransaction.uncategorized.search(search_term).each do |bank_transaction|
          total_match_count += 1
          bank_transaction.categories << category
          bank_transaction.save!
          proc_logger.info("BankTransaction##{bank_transaction.id} := `#{search_term}`")
        end
      end
    end

    proc_logger.info("")
    proc_logger.info("=" * 80)
    proc_logger.info("TOTAL CATEGORIES:\t#{Category.count} (#{new_cat_count} new!)")
    proc_logger.info("TOTAL CATEGORIZED:\t#{total_match_count}")
  end
end

