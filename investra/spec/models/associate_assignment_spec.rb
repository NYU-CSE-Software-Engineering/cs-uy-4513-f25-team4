require 'rails_helper'

RSpec.describe 'Associate assignment lifecycle', type: :model do
  let(:company) { Company.create!(name: 'Investra Capital') }
  let(:password_attrs) { { password: 'password', password_confirmation: 'password' } }

  let(:portfolio_manager) do
    User.create!(
      {
        email: 'pm@investra.com',
        first_name: 'Portia',
        last_name: 'Manager',
        role: 'portfolio_manager',
        company: company
      }.merge(password_attrs)
    )
  end

  describe '#assign_as_associate!' do
    it 'promotes a trader to associate trader and links manager/company context' do
      trader = User.create!(
        {
          email: 'trader@investra.com',
          first_name: 'Terry',
          last_name: 'Trader',
          role: 'trader',
          company: company
        }.merge(password_attrs)
      )

      trader.assign_as_associate!(portfolio_manager)

      trader.reload
      expect(trader.role).to eq('associate_trader')
      expect(trader.manager).to eq(portfolio_manager)
      expect(trader.company).to eq(company)
    end
  end

  describe '#remove_associate!' do
    it 'reverts an associate trader back to trader and detaches manager/company links' do
      associate = User.create!(
        {
          email: 'associate@investra.com',
          first_name: 'Avery',
          last_name: 'Associate',
          role: 'associate_trader',
          manager: portfolio_manager,
          company: company
        }.merge(password_attrs)
      )

      associate.remove_associate!

      associate.reload
      expect(associate.role).to eq('trader')
      expect(associate.manager).to be_nil
      expect(associate.company).to be_nil
    end
  end
end
