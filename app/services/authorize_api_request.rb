class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    current_user
  end

  def self.encoded_auth_token(payload, expires_in: 24.hours.from_now)
    payload[:exp] = expires_in.to_i
    payload[:iat] = Time.current.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.http_auth_header(headers)
    headers["Authorization"].split(" ").last if headers["Authorization"].present?
  end

  private

  def current_user
    @user ||= User.find(decoded_auth_token["id"]) if decoded_auth_token
  end

  def decoded_auth_token
    @decoded_auth_token ||= JWT.decode(
      current_token,
      Rails.application.credentials.secret_key_base,
      true,
      algorithm: "HS256"
    ).first
  end

  def current_token
    @current_token ||= AuthorizeApiRequest.http_auth_header(@headers)
    @current_token || raise(StandardError, "Missing token")
  end
end
