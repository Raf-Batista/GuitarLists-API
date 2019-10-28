require 'jwt'

class ApplicationController < ActionController::API

  def login(user)
    payload = {id: user.id, email: user.email, username: user.username}
    token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'

    token
  end

  def verify(user_id, token)
    if !token
      return false
    end

    decoded_token = JWT.decode token, ENV["HMAC_SECRET"], true, { algorithm: 'HS256' }
    user_id.to_i == decoded_token.first["id"] ? true : false
  end
end
