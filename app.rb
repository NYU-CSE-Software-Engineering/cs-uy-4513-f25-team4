# app.rb
require 'sinatra/base'

class MyApp < Sinatra::Base

  # 允许所有主机访问（开发环境用）
  set :host_authorization, { permitted_hosts: [] }  

  # 定义根路由 GET /
  get '/' do
    '<!DOCTYPE html><html><body><h1>Good bye</h1></body></html>'
  end

end
