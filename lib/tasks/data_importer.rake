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
  task import_bank_bank_transactions: :environment do
    # Setup
    log_datetime = DateTime.now.strftime("%Y%jT%H%M%S")
    err_log_file = "import-errors_#{log_datetime}.log"
    proc_log_file = "import-progress_#{log_datetime}.log"
    error_logger = Logger.new(File.open(LOG_DIR + err_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    proc_logger = Logger.new(File.open(LOG_DIR + proc_log_file,
                              File::WRONLY | File::APPEND | File::CREAT))
    row_i = 0; bank_transaction_errors = 0; bank_transactions_added = 0

    # Import filename variable
    import_filename = 'PRIMARY_BUSINESS_CHK_XXXXXX5199.csv'

    # Main Import
    Benchmark.bm do |marker|
      marker.report("import_to_db") do
        CSV.foreach(IMPORT_FILE_DIR + import_filename) do |bank_transaction_row|
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

end

