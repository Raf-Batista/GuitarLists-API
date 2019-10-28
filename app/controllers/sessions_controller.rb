class SessionsController < ApplicationController

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      token = login(@user)
      render json: {email: @user.email, username: @user.username, id: @user.id, token: token}
    else
      render json: {errors: "Invalid credentials"}
    end
  end

  def token
    if params[:token]
      decoded_token = JWT.decode params[:token], ENV["HMAC_SECRET"], true, { algorithm: 'HS256' }
      render json: {email: decoded_token.first["email"], username: decoded_token.first["username"], id: decoded_token.first["id"]}
    end
  end

  def destroy
    session.clear
  end
end
