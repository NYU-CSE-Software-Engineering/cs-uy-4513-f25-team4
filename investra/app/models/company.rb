class Company < ApplicationRecord
  has_many :users

  before_validation :ensure_defaults
  before_save :normalize_ticker

  validates :name, presence: true
  validates :ticker, presence: true, uniqueness: { case_sensitive: false }
  validates :sector, presence: true

  private

  def ensure_defaults
    self.ticker = generated_ticker if ticker.blank? && name.present?
    self.sector = "General" if sector.blank?
  end

  def normalize_ticker
    self.ticker = ticker&.upcase
  end

  def generated_ticker
    base = name.to_s.gsub(/[^A-Za-z]/, "").upcase[0, 4]
    base = "COMP" if base.blank?

    candidate = base
    suffix = 1
    while Company.where.not(id: id).exists?(ticker: candidate)
      candidate = "#{base}#{suffix}"
      suffix += 1
    end
    candidate
  end
end
