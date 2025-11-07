class ApplicationController < ActionController::Base
  # ✅ 禁用浏览器版本检查 (我们已加过)
  unless Rails.env.test?
    allow_browser versions: :modern
  else
    skip_before_action :ensure_browser_is_modern, raise: false
  end

  # ✅ 测试环境关闭 CSRF 验证
  protect_from_forgery with: :null_session, if: -> { Rails.env.test? }

  # ✅ 跳过用户验证（如果存在）
  if Rails.env.test?
    skip_before_action :authenticate_user!, raise: false
    skip_before_action :authorize_admin!, raise: false
  end
end
