require 'rails_helper'

RSpec.describe News, type: :model do
  let(:stock) { Stock.create!(symbol: 'AAPL', name: 'Apple Inc.', price: 150.00, available_quantity: 1000) }
  
  describe 'associations' do
    it { should belong_to(:stock) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:stock) }
    it { should validate_presence_of(:published_at) }
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

