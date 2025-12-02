require 'rails_helper'

RSpec.describe 'Stocks', type: :request do
  let(:user) do
    User.create!(
      email: 'test@example.com',
      password: 'SecurePass123',
      password_confirmation: 'SecurePass123',
      first_name: 'John',
      last_name: 'Doe',
      balance: 5000.00
    )
  end

  let(:stock) do
    Stock.create!(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      price: 150.00,
      available_quantity: 1000
    )
  end

  before do
    # Simulate login by setting session
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:session).and_return({ user_id: user.id })
  end

  describe 'GET /stocks' do
    it 'renders the index template' do
      get stocks_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it 'displays available stocks' do
      stock
      get stocks_path
      expect(response.body).to include('AAPL')
      expect(response.body).to include('Apple Inc.')
    end
  end

  describe 'POST /stocks/:id/buy' do
    it 'creates a buy transaction and updates user balance' do
      expect {
        post buy_stock_path(stock), params: { quantity: 10 }
      }.to change(Transaction, :count).by(1)
        .and change { user.reload.balance }.by(-1500.00)

      transaction = Transaction.last
      expect(transaction.transaction_type).to eq('buy')
      expect(transaction.quantity).to eq(10)
      expect(transaction.user).to eq(user)
      expect(transaction.stock).to eq(stock)
    end

    it 'creates or updates portfolio entry' do
      post buy_stock_path(stock), params: { quantity: 10 }
      portfolio = Portfolio.find_by(user: user, stock: stock)
      expect(portfolio).not_to be_nil
      expect(portfolio.quantity).to eq(10)
    end

    it 'returns error if insufficient balance' do
      user.update(balance: 100.00)
      post buy_stock_path(stock), params: { quantity: 10 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Insufficient balance')
    end

    it 'returns error if invalid quantity' do
      post buy_stock_path(stock), params: { quantity: 'abc' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Please enter a valid quantity')
    end
  end

  describe 'POST /stocks/:id/sell' do
    before do
      Portfolio.create!(user: user, stock: stock, quantity: 10)
    end

    it 'creates a sell transaction and updates user balance' do
      expect {
        post sell_stock_path(stock), params: { quantity: 5 }
      }.to change(Transaction, :count).by(1)
        .and change { user.reload.balance }.by(750.00)

      transaction = Transaction.last
      expect(transaction.transaction_type).to eq('sell')
      expect(transaction.quantity).to eq(5)
    end

    it 'updates portfolio quantity' do
      post sell_stock_path(stock), params: { quantity: 5 }
      portfolio = Portfolio.find_by(user: user, stock: stock)
      expect(portfolio.quantity).to eq(5)
    end

    it 'returns error if insufficient shares' do
      post sell_stock_path(stock), params: { quantity: 20 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Insufficient shares')
    end
  end
end

