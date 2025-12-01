class User < ApplicationRecord
  has_secure_password

  belongs_to :company, optional: true
  belongs_to :manager, class_name: "User", optional: true
  has_many :associates, class_name: "User", foreign_key: :manager_id, dependent: :nullify

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  before_validation :normalize_email
  after_commit :sync_role_to_roles_table, on: [:create, :update]

  validates :email, presence: true, uniqueness: { case_sensitive: false, message: "is already taken" }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }

  # Promote a trader to associate trader under the given manager
  def assign_as_associate!(manager_user)
    associate_role = Role.find_or_create_by!(name: "Associate Trader")

    transaction do
      self.roles = [associate_role]
      update!(role: "associate_trader", manager: manager_user, company: manager_user&.company)
    end

    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  # Demote an associate back to trader and clear manager/company
  def remove_associate!
    trader_role = Role.find_or_create_by!(name: "Trader")

    transaction do
      self.roles = [trader_role]
      update!(role: "trader", manager: nil, company: nil)
    end

    true
  rescue ActiveRecord::ActiveRecordError
    false
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def sync_role_to_roles_table
    return if role.blank?

    primary_role = Role.find_or_create_by!(name: role)
    user_roles.find_or_create_by!(role: primary_role)
  end
end
