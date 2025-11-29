class User < ApplicationRecord
  has_secure_password
  
  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  belongs_to :company, optional: true
  belongs_to :manager, class_name: "User", optional: true
  has_many :associates, class_name: "User", foreign_key: "manager_id"
  
  # Validations
  validates :email, presence: true, uniqueness: { message: "is already taken" }
  validates :first_name, :last_name, presence: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  
  before_validation :normalize_email

  def assign_as_associate!(manager)
    update!(manager: manager, company: manager.company)
  end
  
  def remove_associate!
    update!(manager: nil, company: nil)
  end
  
  def assign_as_admin!
    admin_role = Role.find_by(name: 'System Administrator')
    roles << admin_role unless roles.include?(admin_role)
  end
  
  private
  
  def normalize_email
    self.email = email&.strip&.downcase
  end
end
