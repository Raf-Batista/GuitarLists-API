require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe "GET #create" do
    it "successfully logs in" do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      get :create, params: {email: 'test@email.com', password: 'test123'}
      json_response = JSON.parse(response.body)
      expect(json_response["token"]).to be_truthy

    end

    it "returns JSON with errors if user did not log in" do
      User.create(email: 'test@email.com', username: 'test', password: 'test123')
      post :create, params: {email: 'test@email.com', usename: 'test', password: 'test'}
      json_response = JSON.parse(response.body)
      expect(json_response["errors"]).to be_truthy
    end
  end
end
