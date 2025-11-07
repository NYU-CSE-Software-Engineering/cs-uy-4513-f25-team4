require 'rails_helper'

RSpec.describe User, type: :model do
  let(:company) { Company.create!(name: 'Test Holdings') }
  subject(:user) do
    described_class.new(
      email: 'pm@example.com',
      role: 'portfolio_manager',
      first_name: 'Pat',
      last_name: 'Manager',
      company: company
    )
  end

  describe 'validations' do
    it 'is invalid without an email' do
      user.email = nil

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without a role' do
      user.role = nil

      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end

    it 'is invalid when another user already uses the email (case-insensitive)' do
      described_class.create!(
        email: 'pm@example.com',
        role: 'portfolio_manager',
        first_name: 'Existing',
        last_name: 'Manager',
        company: company
      )
      duplicate = described_class.new(
        email: 'PM@example.com',
        role: 'associate_trader',
        first_name: 'Alex',
        last_name: 'Associate',
        company: company
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end

  describe 'associations' do
    pending 'adds belongs_to :company once companies are modeled'
  end
end
