module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
    rescue_from StandardError, with: :handle_not_authorized
    rescue_from JWT::DecodeError, with: :handle_jwt_invalid
    rescue_from JWT::ExpiredSignature, with: :handle_jwt_expired
  end

  def encoded_auth_token(user)
    payload = { id: user.id, email: user.email }
    AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 1.hours.from_now)
  end

  def encoded_refresh_token(user)
    payload = { id: user.id, email: user.email }
    refresh_token = AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 7.days.from_now)
    @user.update(refresh_token: refresh_token)
    refresh_token
  end

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    handle_not_authorized unless @current_user
  end

  def handle_jwt_expired
    render json: { error: "Token has expired" }, status: :unauthorized
  end

  def handle_jwt_invalid
    render json: { error: "Invalid token" }, status: :unauthorized
  end

  def handle_not_authorized
    render json: { error: "Not authorized" }, status: :unauthorized
  end
end
