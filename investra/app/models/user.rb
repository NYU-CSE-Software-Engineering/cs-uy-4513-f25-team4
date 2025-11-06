class User < ApplicationRecord
  belongs_to :company, optional: true
  belongs_to :manager, class_name: "User", optional: true
  has_many :associates, class_name: "User", foreign_key: "manager_id"

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, :role, presence: true

  # --- Associate assignment methods ---
  def assign_as_associate!(manager)
    update!(role: "associate_trader", manager: manager, company: manager.company)
  end

  def remove_associate!
    update!(role: "trader", manager: nil, company: nil)
  end

  private

  def downcase_email
    self.email = email&.downcase
  end
end