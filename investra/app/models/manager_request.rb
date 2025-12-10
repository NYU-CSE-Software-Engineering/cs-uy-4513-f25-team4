class ManagerRequest < ApplicationRecord
  belongs_to :user
  belongs_to :manager, class_name: "User"

  STATUSES = %w[pending approved rejected].freeze

  validates :status, inclusion: { in: STATUSES }
end
