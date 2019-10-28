require 'rails_helper'

RSpec.describe UsersController do

    describe 'Get #index' do
      let!(:users) do
        3.times do |index|
          user = User.create(email: "test#{index+1}@email.com", username: "test#{index+1}", password: "test123")
          user.guitars.build(model: "test-model#{index+1}", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
          user.guitars.build(model: "test-model#{index+10}", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
        end
      end

      before(:example) { get :index }

      it 'returns HTTP Success' do
        expect(response).to have_http_status(:success)
      end

      it 'should return the correct number of users' do
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(3)
      end

      it 'should return with the correct keys' do
        json_response = JSON.parse(response.body)
        expect(json_response[0].keys).to match(["id", "email", "username", "guitars"])
      end

      it 'should return an array of guitars' do
        json_response = JSON.parse(response.body)
        expect(json_response[0]["guitars"].class).to eq(Array)
      end

      it 'should return correct number of guitars' do
        json_response = JSON.parse(response.body)
        expect(json_response[0]["guitars"].size).to eq(2)
      end
  end

  describe 'Get #show' do
    let!(:user) do
      user = User.create(email: "test@email.com", username: 'test', password: "test123")
      user.guitars.build(model: "test-model-1", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      user.guitars.build(model: "test-model-2", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      payload = {email: user.email, username: user.username}
      @token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'
    end

    it 'returns HTTP success' do
       get :show, params: {id: User.first.id}
      expect(response).to have_http_status(:success)
    end

    it 'does not return created_at and updated_at' do
      get :show, params: {id: User.first.id}
      json_response = JSON.parse(response.body)
      expect(json_response.keys).to match(["id", "email", "username", "guitars"])
    end

    it 'returns an array of guitars' do
      get :show, params: {id: User.first.id}
      json_response = JSON.parse(response.body)
      expect(json_response["guitars"].class).to eq(Array)
    end

    it 'returns an correct number of guitars' do
      get :show, params: {id: User.first.id}
      json_response = JSON.parse(response.body)
      expect(json_response["guitars"].size).to eq(2)
    end
  end

  describe 'Post #create' do
    it 'successfully creates a user ' do
      post :create, params: { user: {email: 'test@email.com', username: 'test', password: 'test123'} }
      expect(User.all.size).to eq(1)
    end

    it 'sends a welcome email after creating a user' do
      post :create, params: { user: {email: 'test@email.com', username: 'test', password: 'test123'} }
      expect(ActionMailer::Base.deliveries.last.to[0]).to eq('test@email.com')
    end

    it 'logs in a user after create ' do
      post :create, params: { user: {email: 'test@email.com', username: 'test', password: 'test123'} }
      json_response = JSON.parse(response.body)
      expect(json_response["token"]).to be_truthy
    end

    it 'renders newly created user ' do
      post :create, params: { user: {email: 'test@email.com', username: 'tests', password: 'test123'} }
      json_response = JSON.parse(response.body)
      expect(json_response["email"]).to eq('test@email.com')
    end

    it 'renders user error message when creating user that exists' do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      post :create, params: { user: {email: 'test@email.com', username: 'test', password: 'test123'} }
      json_response = JSON.parse(response.body)
      expect(json_response["errors"][0]).to eq('Email has already been taken')
    end

    it 'renders password error message when password is too short' do
      post :create, params: { user: {email: 'test@email.com', username: 'test', password: 'test'} }
      json_response = JSON.parse(response.body)
      expect(json_response["errors"][0]).to eq('Password is too short (minimum is 5 characters)')
    end
  end

  describe 'Patch #update' do
    before(:example) do
      @user = User.create(email: 'before@email.com', username: 'test', password: 'test123')
      payload = {id: @user.id, email: @user.email, username: @user.username}
      @token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'
    end

    it 'successfully updates username' do
      patch :update, params: { id: @user.id, user: {email: 'after@email.com'}, token: @token}
      expect(User.first.email).to eq('after@email.com')
    end

    it 'successfully updates password' do
      User.create(email: 'before@email.com', username: 'test', password: 'test123')
      patch :update, params: { id: 1, user: {password: 'password_has_changed'}, token: @token }
      expect(User.first.authenticate('password_has_changed')).to be_truthy
    end

    it 'renders updated seller' do
      User.create(email: 'before@email.com', username: 'test', password: 'test123')
      patch :update, params: { id: 1, user: {email: 'after@email.com'}, token: @token }
      json_response = JSON.parse(response.body)
      expect(json_response["email"]).to eq('after@email.com')
    end

    it 'Will not update username if not logged in as seller' do
      User.create(email: 'not_allowed@email.com', username: 'test2', password: 'test123')
      patch :update, params: { id: 2, user: {email: 'username_has_been_changed'} , token: @token }

      json_response = JSON.parse(response.body)
      expect(User.first.email).to eq('before@email.com')
      expect(json_response["errors"]).to eq('You are not logged in')
    end

  end

  describe 'Delete #destroy' do
    before(:example) do
      @user = User.create(email: 'test@email.com', username: 'test', password: 'test123')
      payload = {id: @user.id, email: @user.email, username: @user.username}
      @token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'
    end

    it 'successfully deletes a user' do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      delete :destroy, params: {id: 1, token: @token}
      expect(User.all.size).to eq(0)
    end

    it 'does not delete another user' do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      delete :destroy, params: {id: 1}
      expect(User.all.size).to eq(1)
    end

    it 'renders a JSON message after deleting a seller' do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      delete :destroy, params: {id: 1, token: @token}
      json_response = JSON.parse(response.body)
      expect(json_response["message"]).to eq('Your account has been deleted')
    end

    it "renders a JSON message when trying to delete seller that doesn't exist" do
      User.delete_all
      delete :destroy, params: {id: 1}
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to eq('There was an error')
    end
  end
end
