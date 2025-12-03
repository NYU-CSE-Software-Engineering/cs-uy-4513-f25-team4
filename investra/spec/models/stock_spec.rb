require 'rails_helper'

RSpec.describe Stock, type: :model do
  describe 'validations' do
    it 'requires a symbol' do
      stock = Stock.new(name: 'Apple Inc.', price: 150.00, available_quantity: 1000)
      expect(stock).not_to be_valid
      expect(stock.errors[:symbol]).to include("can't be blank")
    end

    it 'requires a name' do
      stock = Stock.new(symbol: 'AAPL', price: 150.00, available_quantity: 1000)
      expect(stock).not_to be_valid
      expect(stock.errors[:name]).to include("can't be blank")
    end

    it 'requires a price' do
      stock = Stock.new(symbol: 'AAPL', name: 'Apple Inc.', available_quantity: 1000)
      expect(stock).not_to be_valid
      expect(stock.errors[:price]).to include("can't be blank")
    end

    it 'requires price to be greater than 0' do
      stock = Stock.new(symbol: 'AAPL', name: 'Apple Inc.', price: -10, available_quantity: 1000)
      expect(stock).not_to be_valid
      expect(stock.errors[:price]).to include('must be greater than 0')
    end

    it 'requires available_quantity to be present' do
      stock = Stock.new(symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: nil)
      expect(stock).not_to be_valid
      expect(stock.errors[:available_quantity]).to include("can't be blank")
    end

    it 'requires available_quantity to be greater than or equal to 0' do
      stock = Stock.new(symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: -1)
      expect(stock).not_to be_valid
      expect(stock.errors[:available_quantity]).to include('must be greater than or equal to 0')
    end

    it 'is valid with all required attributes' do
      stock = Stock.new(symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: 1000)
      expect(stock).to be_valid
    end
  end

  describe 'associations' do
    it 'has many portfolios' do
      association = Stock.reflect_on_association(:portfolios)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
    end

    it 'has many transactions' do
      association = Stock.reflect_on_association(:transactions)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
    end
  end
end
