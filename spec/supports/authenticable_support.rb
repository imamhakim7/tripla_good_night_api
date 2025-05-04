module AuthenticableSupport
  def authenticated_header(user)
    payload = { id: user.id, email: user.email }
    { 'Authorization' => "Bearer #{AuthorizeApiRequest.encoded_auth_token(payload, expires_in: 1.hours.from_now)}" }
  end
end
