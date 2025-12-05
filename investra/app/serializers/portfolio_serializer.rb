class PortfolioSerializer
  def initialize(summary)
    @summary = summary
  end

  def as_json(*)
    {
      user_id: @summary[:user_id],
      total_value: @summary[:total_value],
      cash_balance: @summary[:cash_balance],
      holdings: @summary[:holdings]
    }
  end
end
