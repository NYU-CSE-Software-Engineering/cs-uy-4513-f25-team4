class AddDomainToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :domain, :string
  end
end
