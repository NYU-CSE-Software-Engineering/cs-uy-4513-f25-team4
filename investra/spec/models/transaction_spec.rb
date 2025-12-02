require 'rails_helper'

RSpec.describe Transaction, type: :model do
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

  describe 'validations' do
    it 'requires a user' do
      transaction = Transaction.new(stock: stock, quantity: 10, transaction_type: 'buy', price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:user]).to include("can't be blank")
    end

    it 'requires a stock' do
      transaction = Transaction.new(user: user, quantity: 10, transaction_type: 'buy', price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:stock]).to include("can't be blank")
    end

    it 'requires a quantity' do
      transaction = Transaction.new(user: user, stock: stock, transaction_type: 'buy', price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:quantity]).to include("can't be blank")
    end

    it 'requires quantity to be greater than 0' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 0, transaction_type: 'buy', price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:quantity]).to include('must be greater than 0')
    end

    it 'requires a transaction_type' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include("can't be blank")
    end

    it 'requires transaction_type to be either buy or sell' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, transaction_type: 'invalid', price: 150.00)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include('is not included in the list')
    end

    it 'requires a price' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, transaction_type: 'buy')
      expect(transaction).not_to be_valid
      expect(transaction.errors[:price]).to include("can't be blank")
    end

    it 'requires price to be greater than 0' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, transaction_type: 'buy', price: -10)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:price]).to include('must be greater than 0')
    end

    it 'is valid with all required attributes for buy' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, transaction_type: 'buy', price: 150.00)
      expect(transaction).to be_valid
    end

    it 'is valid with all required attributes for sell' do
      transaction = Transaction.new(user: user, stock: stock, quantity: 10, transaction_type: 'sell', price: 150.00)
      expect(transaction).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      association = Transaction.reflect_on_association(:user)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a stock' do
      association = Transaction.reflect_on_association(:stock)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'scopes' do
    it 'has a buy scope' do
      Transaction.create!(user: user, stock: stock, quantity: 10, transaction_type: 'buy', price: 150.00)
      Transaction.create!(user: user, stock: stock, quantity: 5, transaction_type: 'sell', price: 150.00)
      expect(Transaction.buy.count).to eq(1)
      expect(Transaction.buy.first.transaction_type).to eq('buy')
    end

    it 'has a sell scope' do
      Transaction.create!(user: user, stock: stock, quantity: 10, transaction_type: 'buy', price: 150.00)
      Transaction.create!(user: user, stock: stock, quantity: 5, transaction_type: 'sell', price: 150.00)
      expect(Transaction.sell.count).to eq(1)
      expect(Transaction.sell.first.transaction_type).to eq('sell')
    end
  end
end
