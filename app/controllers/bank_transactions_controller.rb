class BankTransactionsController < ApplicationController
  before_action :set_bank_transaction, only: [:show, :edit, :update, :destroy]

  # GET /bank_transactions
  # GET /bank_transactions.json
  def index
    @search_term = params[:search_term]
    @category = Category.find_by_id(params[:category_id])

    if @category.present?
      @bank_transactions = @category.bank_transactions
    elsif @search_term.present?
      @bank_transactions = BankTransaction.search(@search_term)
    else
      @bank_transactions = BankTransaction.all
    end

    respond_to do |format|
      format.html
      format.csv { send_data @bank_transactions.to_csv }
    end
  end

  # GET /bank_transactions/1
  # GET /bank_transactions/1.json
  def show
  end

  # GET /bank_transactions/new
  def new
    @bank_transaction = BankTransaction.new
  end

  # GET /bank_transactions/1/edit
  def edit
  end

  # POST /bank_transactions
  # POST /bank_transactions.json
  def create
    @bank_transaction = BankTransaction.new(bank_transaction_params)

    respond_to do |format|
      if @bank_transaction.save
        format.html { redirect_to @bank_transaction, notice: 'BankTransaction was successfully created.' }
        format.json { render :show, status: :created, location: @bank_transaction }
      else
        format.html { render :new }
        format.json { render json: @bank_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_transactions/1
  # PATCH/PUT /bank_transactions/1.json
  def update
    respond_to do |format|
      if @bank_transaction.update(bank_transaction_params)
        format.html { redirect_to @bank_transaction, notice: 'BankTransaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_transaction }
      else
        format.html { render :edit }
        format.json { render json: @bank_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_transactions/1
  # DELETE /bank_transactions/1.json
  def destroy
    @bank_transaction.destroy
    respond_to do |format|
      format.html { redirect_to bank_transactions_url, notice: 'BankTransaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bank_transaction
      @bank_transaction = BankTransaction.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_transaction_params
      params.require(:bank_transaction).permit(:reported_date, :reported_amount, :reported_description, :is_complete)
    end
end
