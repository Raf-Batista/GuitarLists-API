require "rails_helper"

RSpec.describe UserMailer, type: :mailer do

  describe "welcome" do

    it "has the correct subject in the mail" do
      user = User.create(email: 'test@example.com', username: 'test', password: 'test123')
      UserMailer.welcome(user).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq('Welcome to GuitarLists')
    end

    it "is sent to the newly creted user" do
      user = User.create(email: 'test@example.com', username: 'test', password: 'test123')
      UserMailer.welcome(user).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq(user.email)
    end

    it "is sent from GuitarLists" do
      user = User.create(email: 'test@example.com', username: 'test', password: 'test123')
      UserMailer.welcome(user).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.from[0]).to eq("#{ENV["GUITARLISTS_USERNAME"]}@gmail.com")
    end

  end

  describe "message" do

    it "has the correct subject in the mail" do
      user = User.create(email: 'buyer@example.com', username: 'buyer', password: 'password')
      seller = User.create(email: 'seller@example.com', username: 'seller', password: 'password')
      seller.guitars.build(model: "test-model", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      message = "this is a test message"
      UserMailer.message_user(user, message, seller, seller.guitars.last).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq("Message from #{user.email} about #{seller.guitars.last.model}")
    end 

    it "is sent to the user selling the guitar" do
      user = User.create(email: 'buyer@example.com', username: 'buyer', password: 'password')
      seller = User.create(email: 'seller@example.com', username: 'seller', password: 'password')
      seller.guitars.build(model: "test-model", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      message = "this is a test message"
      UserMailer.message_user(user, message, seller, seller.guitars.last ).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to[0]).to eq(seller.email)
    end 

    it "is sent from the user buying the guitar" do
      user = User.create(email: 'buyer@example.com', username: 'buyer', password: 'password')
      seller = User.create(email: 'seller@example.com', username: 'seller', password: 'password')
      seller.guitars.build(model: "test-model", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      message = "this is a test message"
      UserMailer.message_user(user, message, seller, seller.guitars.last ).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.from[0]).to eq(user.email)
    end 


    it "is is sent with the correct message" do
      user = User.create(email: 'buyer@example.com', username: 'buyer', password: 'password')
      seller = User.create(email: 'seller@example.com', username: 'seller', password: 'password')
      seller.guitars.build(model: "test-model", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      message = "this is a test message"
      UserMailer.message_user(user, message, seller, seller.guitars.last ).deliver_now
      mail = ActionMailer::Base.deliveries.last
      expect(mail.body.encoded).to match(message)
    end 
  end 
end
