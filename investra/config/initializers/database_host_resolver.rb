# Resolve Docker container hostname to localhost when running tests locally
# This allows database.yml to use 'investra-db-1' while tests run from host machine
if Rails.env.test? && !ENV['DB_HOST']
  require 'resolv'
  
  begin
    # Try to resolve investra-db-1
    Resolv.getaddress('investra-db-1')
  rescue Resolv::ResolvError
    # Hostname doesn't resolve, so we're running locally
    # Set DB_HOST to localhost so database.yml uses the correct host
    ENV['DB_HOST'] = 'localhost'
  end
end

