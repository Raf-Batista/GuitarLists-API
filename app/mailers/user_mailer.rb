class UserMailer < ApplicationMailer

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to GuitarLists')
  end

  def message_user(user, message, seller, guitar) 
    @user = user 
    @message = message
    @seller = seller 
    @guitar = guitar
    mail(from: @user.email, to: @seller.email, subject: "Message from #{@user.email} about #{@guitar.model}")
  end 
end
