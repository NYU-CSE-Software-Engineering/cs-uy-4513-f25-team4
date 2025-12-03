require 'rails_helper'

RSpec.describe Portfolio, type: :model do
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
      portfolio = Portfolio.new(stock: stock, quantity: 10)
      expect(portfolio).not_to be_valid
      expect(portfolio.errors[:user]).to include("must exist")
    end

    it 'requires a stock' do
      portfolio = Portfolio.new(user: user, quantity: 10)
      expect(portfolio).not_to be_valid
      expect(portfolio.errors[:stock]).to include("must exist")
    end

    it 'requires a quantity' do
      portfolio = Portfolio.new(user: user, stock: stock)
      expect(portfolio).not_to be_valid
      expect(portfolio.errors[:quantity]).to include("can't be blank")
    end

    it 'requires quantity to be greater than 0' do
      portfolio = Portfolio.new(user: user, stock: stock, quantity: 0)
      expect(portfolio).not_to be_valid
      expect(portfolio.errors[:quantity]).to include('must be greater than 0')
    end

    it 'is valid with all required attributes' do
      portfolio = Portfolio.new(user: user, stock: stock, quantity: 10)
      expect(portfolio).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      association = Portfolio.reflect_on_association(:user)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a stock' do
      association = Portfolio.reflect_on_association(:stock)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'uniqueness' do
    it 'allows only one portfolio entry per user-stock combination' do
      Portfolio.create!(user: user, stock: stock, quantity: 10)
      duplicate = Portfolio.new(user: user, stock: stock, quantity: 5)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:stock_id]).to include('has already been taken')
    end

    it 'allows different users to have the same stock' do
      user2 = User.create!(
        email: 'test2@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Jane',
        last_name: 'Doe',
        balance: 5000.00
      )
      Portfolio.create!(user: user, stock: stock, quantity: 10)
      portfolio2 = Portfolio.new(user: user2, stock: stock, quantity: 5)
      expect(portfolio2).to be_valid
    end
  end
end
