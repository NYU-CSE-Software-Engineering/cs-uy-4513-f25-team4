require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /signup" do
    it "renders the new template" do
      get signup_path
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end
end
