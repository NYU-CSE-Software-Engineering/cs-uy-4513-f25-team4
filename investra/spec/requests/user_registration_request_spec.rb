require 'rails_helper'

RSpec.describe "User Registration", type: :request do
  before(:each) do
    # Create roles that are needed for tests
    Role.find_or_create_by!(name: 'Trader') { |r| r.description = 'Individual investor' }
    Role.find_or_create_by!(name: 'Associate Trader') { |r| r.description = 'Company employee trader' }
    Role.find_or_create_by!(name: 'Portfolio Manager') { |r| r.description = 'Company manager' }
  end

  describe "GET /signup" do
    it "returns http success" do
      get '/signup'
      expect(response).to have_http_status(:success)
    end

    it "renders the registration form" do
      get '/signup'
      expect(response.body).to include('Sign Up')
      expect(response.body).to include('Email')
      expect(response.body).to include('Password')
    end
  end

  describe "POST /signup" do
    context "with valid parameters for Trader" do
      let(:valid_params) do
        {
          user: {
            email: 'newuser@example.com',
            password: 'SecurePass123',
            password_confirmation: 'SecurePass123',
            first_name: 'John',
            last_name: 'Doe'
          },
          role_name: 'Trader'
        }
      end

      it "creates a new user" do
        expect {
          post '/signup', params: valid_params
        }.to change(User, :count).by(1)
      end

      it "assigns the Trader role" do
        post '/signup', params: valid_params
        user = User.last
        expect(user.roles.pluck(:name)).to include('Trader')
      end

      it "redirects to trader dashboard" do
        post '/signup', params: valid_params
        expect(response).to redirect_to('/dashboard/trader')
      end

      it "creates a session" do
        post '/signup', params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end

      it "shows success message" do
        post '/signup', params: valid_params
        follow_redirect!
        expect(response.body).to include('Registration successful')
      end
    end

    context "with valid parameters for Portfolio Manager with existing company" do
      let!(:company) { Company.create!(name: 'TestCorp Inc', domain: 'testcorp.com') }
      let(:valid_params) do
        {
          user: {
            email: 'manager@testcorp.com',
            password: 'SecurePass123',
            password_confirmation: 'SecurePass123',
            first_name: 'Sarah',
            last_name: 'Manager'
          },
          role_name: 'Portfolio Manager'
        }
      end

      it "creates a new user" do
        expect {
          post '/signup', params: valid_params
        }.to change(User, :count).by(1)
      end

      it "assigns Portfolio Manager role" do
        post '/signup', params: valid_params
        user = User.last
        expect(user.roles.pluck(:name)).to include('Portfolio Manager')
      end

      it "associates user with existing company" do
        post '/signup', params: valid_params
        user = User.last
        expect(user.company).to eq(company)
      end

      it "redirects to manager dashboard" do
        post '/signup', params: valid_params
        expect(response).to redirect_to('/dashboard/manager')
      end
    end

    context "with valid parameters for Portfolio Manager with new company" do
      let(:valid_params) do
        {
          user: {
            email: 'ceo@newstartup.com',
            password: 'SecurePass123',
            password_confirmation: 'SecurePass123',
            first_name: 'Alice',
            last_name: 'CEO'
          },
          role_name: 'Portfolio Manager',
          company_name: 'NewStartup Inc'
        }
      end

      it "creates a new user" do
        expect {
          post '/signup', params: valid_params
        }.to change(User, :count).by(1)
      end

      it "creates a new company" do
        expect {
          post '/signup', params: valid_params
        }.to change(Company, :count).by(1)
      end

      it "creates company with correct domain" do
        post '/signup', params: valid_params
        company = Company.last
        expect(company.domain).to eq('newstartup.com')
      end

      it "creates company with provided name" do
        post '/signup', params: valid_params
        company = Company.last
        expect(company.name).to eq('NewStartup Inc')
      end

      it "associates user with new company" do
        post '/signup', params: valid_params
        user = User.last
        expect(user.company.name).to eq('NewStartup Inc')
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          user: {
            email: '',
            password: 'short',
            password_confirmation: 'short',
            first_name: '',
            last_name: ''
          },
          role_name: 'Trader'
        }
      end

      it "does not create a user" do
        expect {
          post '/signup', params: invalid_params
        }.not_to change(User, :count)
      end

      it "renders the registration form again" do
        post '/signup', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error messages" do
        post '/signup', params: invalid_params
      expect(response.body).to include("Email can&#39;t be blank")
      end
    end

    context "with duplicate email" do
      before do
        User.create!(
          email: 'existing@example.com',
          password: 'SecurePass123',
          password_confirmation: 'SecurePass123',
          first_name: 'Existing',
          last_name: 'User'
        )
      end

      let(:duplicate_params) do
        {
          user: {
            email: 'existing@example.com',
            password: 'SecurePass123',
            password_confirmation: 'SecurePass123',
            first_name: 'New',
            last_name: 'User'
          },
          role_name: 'Trader'
        }
      end

      it "does not create a user" do
        expect {
          post '/signup', params: duplicate_params
        }.not_to change(User, :count)
      end

      it "shows email taken error" do
        post '/signup', params: duplicate_params
        expect(response.body).to include("is already taken")
      end
    end

    context "with password less than 8 characters" do
      let(:short_password_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'Short1',
            password_confirmation: 'Short1',
            first_name: 'Test',
            last_name: 'User'
          },
          role_name: 'Trader'
        }
      end

      it "does not create a user" do
        expect {
          post '/signup', params: short_password_params
        }.not_to change(User, :count)
      end

      it "shows password length error" do
        post '/signup', params: short_password_params
        expect(response.body).to include('too short')
      end
    end

    context "with mismatched password confirmation" do
      let(:mismatched_params) do
        {
          user: {
            email: 'test@example.com',
            password: 'SecurePass123',
            password_confirmation: 'DifferentPass456',
            first_name: 'Test',
            last_name: 'User'
          },
          role_name: 'Trader'
        }
      end

      it "does not create a user" do
        expect {
          post '/signup', params: mismatched_params
        }.not_to change(User, :count)
      end

      it "shows password confirmation error" do
        post '/signup', params: mismatched_params
        expect(response.body).to include("doesn&#39;t match")
      end
    end
  end
end
