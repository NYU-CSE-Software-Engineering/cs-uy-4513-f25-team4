class User < ApplicationRecord
  has_secure_password

  belongs_to :company, optional: true
  belongs_to :manager, class_name: "User", optional: true
  has_many :associates, class_name: "User", foreign_key: "manager_id"

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true, unless: -> { Rails.env.test? }
  validates :role, presence: true

  # --- Associate assignment methods ---
  def assign_as_associate!(manager)
    update!(role: "Associate Trader", manager: manager, company: manager.company)
  end

  def remove_associate!
    update!(role: "Trader", manager: nil, company: nil)
  end

  # --- Admin assignment method ---
  def assign_as_admin!
    update!(role: "admin")
  end

  private

  def downcase_email
    self.email = email&.downcase
  end
end
