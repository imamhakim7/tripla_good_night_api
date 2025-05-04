module AuthenticableSupport
  def get_bearer_for(user)
    payload = { id: user.id, email: user.email }
    AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 1.hours.from_now)
  end
end

RSpec.configure do |config|
  config.include AuthenticableSupport
end
