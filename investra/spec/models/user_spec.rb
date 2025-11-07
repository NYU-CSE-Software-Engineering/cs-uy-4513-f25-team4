require 'rails_helper'

RSpec.describe User, type: :model do
  let(:company) { Company.create!(name: "Test Corp Inc") }

  describe 'validations' do
    it 'is invalid without an email' do
      user = User.new(first_name: 'Alice', last_name: 'Smith', role: 'Trader', company: company)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without a role' do
      user = User.new(email: 'alice@email.com', first_name: 'Alice', last_name: 'Smith', company: company)
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end

    it 'is invalid without first_name' do
      user = User.new(email: 'alice@email.com', last_name: 'Smith', role: 'Trader', company: company)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is invalid without last_name' do
      user = User.new(email: 'alice@email.com', first_name: 'Alice', role: 'Trader', company: company)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is invalid without a company' do
      user = User.new(email: 'alice@email.com', first_name: 'Alice', last_name: 'Smith', role: 'Trader')
      expect(user).not_to be_valid
      expect(user.errors[:company]).to include("must exist")
    end

    it 'is valid with all attributes' do
      user = User.new(email: 'alice@email.com', first_name: 'Alice', last_name: 'Smith', role: 'Trader', company: company, password: 'password', password_confirmation: 'password')
      expect(user).to be_valid
    end
  end

  describe 'associations' do
    it 'can have a manager' do
      manager = User.create!(email: 'manager@firm.com', first_name: 'Manager', last_name: 'Boss', role: 'Portfolio Manager', company: company, password: 'password', password_confirmation: 'password')
      user = User.new(email: 'bob@email.com', first_name: 'Bob', last_name: 'Smith', role: 'Associate Trader', company: company, manager: manager, password: 'password', password_confirmation: 'password')
      expect(user.manager).to eq(manager)
    end
  end
end
