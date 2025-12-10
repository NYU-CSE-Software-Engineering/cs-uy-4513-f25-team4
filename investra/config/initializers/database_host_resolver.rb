# Resolve Docker container hostname to localhost when running tests locally.
# In sandboxed CI the DNS lookup can be blocked (raises SystemCallError/EPERM),
# so we fall back to localhost without failing boot when resolution is not
# allowed.
if Rails.env.test? && !ENV['DB_HOST']
  require 'resolv'

  begin
    Resolv.getaddress('investra-db-1')
  rescue Resolv::ResolvError, SystemCallError
    ENV['DB_HOST'] = 'localhost'
  end
end
