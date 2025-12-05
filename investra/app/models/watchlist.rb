class Watchlist < ApplicationRecord
  belongs_to :user

  validates :symbol, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validate :symbol_is_valid

  before_validation :normalize_symbol

  scope :for_user, ->(user) { where(user_id: user.id) }

  private

  def normalize_symbol
    self.symbol = symbol.to_s.upcase.strip
  end

  def symbol_is_valid
    return if SymbolValidator.valid?(symbol)

    errors.add(:symbol, "is invalid")
  end
end
