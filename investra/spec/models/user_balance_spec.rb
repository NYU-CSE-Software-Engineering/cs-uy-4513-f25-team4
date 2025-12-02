require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'balance attribute' do
    it 'has a balance attribute' do
      user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 5000.00
      )
      expect(user.balance).to eq(5000.00)
    end

    it 'defaults balance to 0 if not provided' do
      user = User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe'
      )
      expect(user.balance).to eq(0.0)
    end

    it 'allows balance to be updated' do
      user = User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe',
        balance: 1000.00
      )
      user.update(balance: 2000.00)
      expect(user.reload.balance).to eq(2000.00)
    end
  end
end

