require 'rails_helper'

RSpec.describe Company, type: :model do
  describe 'validations' do
    it 'is invalid without a name' do
      company = Company.new
      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many users' do
      company = Company.create!(name: "Test Corp Inc")
      user1 = User.create!(email: 'a@email.com', first_name: 'A', last_name: 'B', role: 'Trader', company: company, password: 'password', password_confirmation: 'password')
      user2 = User.create!(email: 'b@email.com', first_name: 'C', last_name: 'D', role: 'Trader', company: company, password: 'password', password_confirmation: 'password')
      expect(company.users).to include(user1, user2)
    end
  end
end
