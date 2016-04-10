json.array!(@bank_transactions) do |bank_transaction|
  json.extract! bank_transaction, :id, :reported_date, :reported_amount, :reported_description, :is_complete
  json.url bank_transaction_url(bank_transaction, format: :json)
end
