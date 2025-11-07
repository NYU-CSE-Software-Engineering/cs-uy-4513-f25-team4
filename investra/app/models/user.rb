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
