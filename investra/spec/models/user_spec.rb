require 'rails_helper'

RSpec.describe User, type: :model do
  # Test valid user creation
  describe 'valid user creation' do
    it 'creates a valid user with all required attributes' do
      user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe'
      )
      expect(user).to be_valid
    end
  end

  # Validation tests
  describe 'validations' do
    it 'requires an email' do
      user = User.new(
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe'
      )
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires a unique email' do
      User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John',
        last_name: 'Doe'
      )

      duplicate_user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Jane',
        last_name: 'Smith'
      )

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('is already taken')
    end

    it 'requires a first name' do
      user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        last_name: 'Doe'
      )
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'requires a last name' do
      user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'John'
      )
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'requires password to be at least 8 characters' do
      user = User.new(
        email: 'test@example.com',
        password: 'Short1',
        password_confirmation: 'Short1',
        first_name: 'John',
        last_name: 'Doe'
      )
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
    end

    it 'requires password confirmation to match' do
      user = User.new(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'DifferentPass456',
        first_name: 'John',
        last_name: 'Doe'
      )
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  # Password security tests
  describe 'password security' do
    let(:user) do
      User.create!(
        email: 'secure@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Secure',
        last_name: 'User'
      )
    end

    it 'hashes the password' do
      expect(user.password_digest).not_to be_nil
      expect(user.password_digest).not_to eq('SecurePass123')
    end

    it 'uses bcrypt hashing ($2a$ prefix)' do
      expect(user.password_digest).to match(/^\$2a\$/)
    end

    it 'authenticates with correct password' do
      expect(user.authenticate('SecurePass123')).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      expect(user.authenticate('WrongPassword')).to be false
    end

    it 'does not store plain text password' do
      # Check database directly
      db_user = User.find(user.id)
      expect(db_user.password_digest).not_to eq('SecurePass123')
      expect(db_user.password_digest).to match(/^\$2a\$/)
    end
  end

  # Email normalization tests
  describe 'email normalization' do
    it 'converts email to lowercase before saving' do
      user = User.create!(
        email: 'TEST@EXAMPLE.COM',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Test',
        last_name: 'User'
      )
      expect(user.email).to eq('test@example.com')
    end

    it 'strips whitespace from email' do
      user = User.create!(
        email: '  test@example.com  ',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Test',
        last_name: 'User'
      )
      expect(user.email).to eq('test@example.com')
    end
  end

  # Association tests
  describe 'associations' do
    it 'has many roles through user_roles' do
      user = User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Test',
        last_name: 'User'
      )

      trader_role = Role.create!(name: 'Trader')
      manager_role = Role.create!(name: 'Portfolio Manager')

      user.roles << trader_role
      user.roles << manager_role

      expect(user.roles.count).to eq(2)
      expect(user.roles).to include(trader_role, manager_role)
    end

    it 'can belong to a company' do
      company = Company.create!(name: 'TestCorp', domain: 'testcorp.com')
      user = User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Test',
        last_name: 'User',
        company: company
      )

      expect(user.company).to eq(company)
      expect(user.company.name).to eq('TestCorp')
    end

    it 'can exist without a company (optional)' do
      user = User.create!(
        email: 'test@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Test',
        last_name: 'User'
      )

      expect(user.company).to be_nil
      expect(user).to be_valid
    end
  end

  # Multiple user registration
  describe 'multiple users' do
    it 'allows multiple users with different emails' do
      user1 = User.create!(
        email: 'first@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'First',
        last_name: 'User'
      )

      user2 = User.create!(
        email: 'second@example.com',
        password: 'SecurePass123',
        password_confirmation: 'SecurePass123',
        first_name: 'Second',
        last_name: 'User'
      )

      expect(User.count).to be >= 2
      expect(User.all).to include(user1, user2)
    end
  end
end