Rails.application.routes.draw do
  resources :categories
  resources :cards
  resources :bank_transactions
  root 'bank_transactions#index'
end
