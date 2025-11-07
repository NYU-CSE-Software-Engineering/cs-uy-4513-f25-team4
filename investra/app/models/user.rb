class User < ApplicationRecord
  belongs_to :company, optional: true

  before_validation :downcase_email

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true

  private

  def downcase_email
    self.email = email&.downcase
  end
end
    has_secure_password
    
    belongs_to :company
    belongs_to :manager, class_name: 'User', optional: true
  
    validates :email, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :role, presence: true
    
    def assign_as_admin!
      update!(role: "admin")
    end
    
    def update_role!(new_role)
        update!(role: new_role)
    end
  end
