require 'csv'
require 'set'
require 'benchmark'

##
#
# TODO - add ability to pass / set file param(s)
namespace :data_importer do
  IMPORT_FILE_DIR  = "#{Rails.root}/src/"
  LOG_DIR = "#{Rails.root}/log/"

  desc "Imports bank transactions from a specified file."
  task import_bank_transactions: :environment do
    # Setup
    log_datetime = DateTime.now.strftime("%Y%jT%H%M%S")
    err_log_file = "import-errors_#{log_datetime}.log"
    proc_log_file = "import-progress_#{log_datetime}.log"
    error_logger = Logger.new(File.open(LOG_DIR + err_log_file))
    proc_logger = Logger.new(File.open(LOG_DIR + proc_log_file))
    row_i = 0; transaction_errors = 0; transactions_added = 0

    # Import filename variable
    import_filename = 'PRIMARY_BUSINESS_CHK_XXXXXX5199.csv'

    # Main Import
    Benchmark.bm do |marker|
      marker.report("import_to_db") do
        CSV.foreach(IMPORT_FILE_DIR + import_filename) do |transaction_row|
          row_i += 1
          Transaction.new({
            reported_date: transaction_row[0],
            reported_amount: transaction_row[1],
            reported_description: transaction[4]
          })
          begin
            Transaction.save!
            transactions_added += 1
          rescue Exception => e
            transaction_errors += 1
            error_logger.error("Error importing Row##{row_i}: #{transaction_row.inspect}")
          end
        end
      end
      puts "== == == RESULTS == == =="
      puts "Transactions Added:\t#{transactions_added}"
      puts "Import Errors:\t\t#{transaction_errors}"
    end
  end
end

