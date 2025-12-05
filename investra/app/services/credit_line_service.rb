class CreditLineService
  def initialize(user)
    @user = user
  end

  def summary
    credit_line = @user.credit_line || @user.build_credit_line(credit_limit: 0, credit_used: 0)

    {
      credit_limit: credit_line.credit_limit.to_f,
      credit_used: credit_line.credit_used.to_f,
      available_balance: (credit_line.credit_limit - credit_line.credit_used).to_f
    }
  end
end
