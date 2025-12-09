require 'rails_helper'

RSpec.describe News, type: :model do
  let(:stock) { Stock.create!(symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: 1000) }
  
  describe 'associations' do
    it 'belongs to stock' do
      news = News.new(stock: stock, title: 'Test', published_at: Time.current)
      expect(news.stock).to eq(stock)
    end
  end
  
  describe 'validations' do
    it 'requires a title' do
      news = News.new(stock: stock, published_at: Time.current)
      expect(news.valid?).to be false
      expect(news.errors[:title]).to include("can't be blank")
    end
    
    it 'requires a stock' do
      news = News.new(title: 'Test', published_at: Time.current)
      expect(news.valid?).to be false
      expect(news.errors[:stock]).to include("must exist")
    end
    
    it 'requires published_at' do
      news = News.new(stock: stock, title: 'Test')
      expect(news.valid?).to be false
      expect(news.errors[:published_at]).to include("can't be blank")
    end
  end
  
  describe '.recent_for_stock' do
    it 'returns recent news for a specific stock' do
      news1 = News.create!(stock: stock, title: 'Old News', published_at: 2.days.ago)
      news2 = News.create!(stock: stock, title: 'New News', published_at: 1.day.ago)
      
      recent = News.recent_for_stock(stock, limit: 10)
      
      expect(recent.first).to eq(news2)
      expect(recent.last).to eq(news1)
    end
  end
end

