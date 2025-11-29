# Create a default admin account on boot for non-production environments.
# This keeps local/test environments usable without manual seeding.
if Rails.env.development? || Rails.env.test?
  Rails.application.config.after_initialize do
    admin_email = "admin@example.com"
    admin_password = "password"

    User.find_or_create_by!(email: admin_email) do |user|
      user.password = admin_password
      user.password_confirmation = admin_password
      user.role = "admin"
      user.first_name = "Admin"
      user.last_name = "User"
    end
  end
end
