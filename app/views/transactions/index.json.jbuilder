json.array!(@transactions) do |transaction|
  json.extract! transaction, :id, :reported_date, :reported_amount, :reported_description, :is_complete
  json.url transaction_url(transaction, format: :json)
end
