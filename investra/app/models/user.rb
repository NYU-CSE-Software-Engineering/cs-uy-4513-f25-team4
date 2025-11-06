class User < ApplicationRecord
    belongs_to :company
    belongs_to :manager, class_name: 'User', optional: true
  
    validates :email, presence: true
    validates :first_name, presence: true
    validates :last_name, presence: true
    validates :role, presence: true
  end
