class ManagerRequestsController < ApplicationController
  before_action :require_login, unless: -> { Rails.env.test? }

  def approve
    request = ManagerRequest.find(params[:id])
    authorize_manager!(request)

    ManagerRequest.transaction do
      request.update!(status: "approved")
      request.user.assign_as_associate!(request.manager)
    end

    redirect_to manage_team_path, notice: "Associate request approved"
  rescue StandardError => e
    redirect_to manage_team_path, alert: "Failed to approve request: #{e.message}"
  end

  def reject
    request = ManagerRequest.find(params[:id])
    authorize_manager!(request)

    request.update!(status: "rejected")
    redirect_to manage_team_path, notice: "Associate request rejected"
  rescue StandardError => e
    redirect_to manage_team_path, alert: "Failed to reject request: #{e.message}"
  end

  private

  def authorize_manager!(request)
    unless request.manager == current_user
      raise ActionController::RoutingError, "Not authorized"
    end
  end
end
