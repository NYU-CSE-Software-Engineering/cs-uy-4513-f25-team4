class SymbolValidator
  # Basic stub to validate ticker symbols. Replace with upstream lookup if available.
  def self.valid?(symbol)
    symbol.to_s.match?(/\A[A-Z]{1,10}\z/)
  end
end
