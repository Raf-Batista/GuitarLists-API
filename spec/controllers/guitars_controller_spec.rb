require 'rails_helper'

RSpec.describe GuitarsController do #, type: :request do
    describe 'Get #index' do
      let!(:users) do
        3.times do |index|
          user = User.create(email: "test#{index+1}@email.com", username: 'test', password: "test123")
          user.guitars.build(model: "test-model#{index+1}", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
          user.guitars.build(model: "test-model#{index+10}", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
        end
      end

      before(:example) { get :index, params: {user_id: 1} }

      it 'returns HTTP success' do
        expect(response).to have_http_status(:success)
      end

      it 'should returns correct number of guitars' do
        json_response = JSON.parse(response.body)
        expect(json_response.size).to eq(6)
      end

      it 'should only returns correct attributes' do
        json_response = JSON.parse(response.body)
        expect(json_response[0].keys).to match(["id", "model", "user_id", "price", "condition", "location", "spec"])
      end

      it 'should return userId' do
        json_response = JSON.parse(response.body)
        expect(json_response[0]["user_id"]).to be_truthy
      end
    end

    describe 'Get #show' do
      let!(:guitar) do
        seller = User.create(email: "test@email.com", username: 'test', password: "test123")
        seller.guitars.build(model: "test-model-1", spec: "test-specs", price: 5, condition: "new", location: "somewhere").save
      end

      before(:example) { get :show, params: {user_id: 1, id: 1} }

      it 'return HTTP success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns a guitar' do
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(Guitar.first.id)
      end

      it "returns a guitar's seller" do
        json_response = JSON.parse(response.body)
        expect(json_response["user_id"]).to eq(User.first.id)
      end

      it "does not return created_at or updated_at" do
        json_response = JSON.parse(response.body)
        expect(json_response.keys).to match(["id", "model", "user_id", "price", "condition", "location", "spec"])
      end
    end

    describe 'Post #create' do
      before(:example) do
        @user = User.create(email: "test@email.com", username: 'test', password: "test123")
        payload = {id: @user.id, email: @user.email, username: @user.username}
        @token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'
      end

      after(:example) do
        Guitar.delete_all
      end

      it 'successfully creates a guitar' do
        post :create, params: {user_id: 1, guitar: {model: 'new_guitar', spec: 'new_spec', price: 5, condition: 'new', location: 'somewhere'}, token: @token}
        expect(User.first.guitars.first).to eq(Guitar.first)
      end

      it 'Renders JSON data after creating a guitar' do
        post :create, params: {user_id: 1, guitar: {model: 'new_guitar', spec: 'new_spec', price: 5, condition: 'new', location: 'somewhere'}, token: @token}

        json_response = JSON.parse(response.body)
        expect(json_response["model"]).to eq("new_guitar")
        expect(json_response["spec"]).to eq("new_spec")
      end

      it 'Renders error message when creating guitar unsuccessful' do
        post :create, params: { user_id: 1, guitar: { model: '', spec: '', price: 5, condition: 'new', location: 'somewhere' }, token: @token }
        json_response = JSON.parse(response.body)
        expect(json_response[0]).to eq("Model can't be blank")
        expect(json_response[1]).to eq("Spec can't be blank")
      end

      it 'will not create a guitar if not logged in' do
        post :create, params: { user_id: 1, guitar: { model: '', spec: '', price: 5, condition: 'new', location: 'somewhere' }}
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq("You are not logged in")
      end

      it 'will not create a guitar with invalid token' do
        post :create, params: { user_id: 2, guitar: { model: '', spec: '', price: 5, condition: 'new', location: 'somewhere' }, token: @token }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq("You are not logged in")
      end
    end

    describe 'Patch #update' do

      before(:example) do
        @user = User.create(email: "test@email.com", username: 'test', password: "test123")
        @user.guitars.build(model: "before_model", spec: "before_spec", price: 5, condition: "new", location: "somewhere").save
        payload = {id: @user.id, email: @user.email, username: @user.username}
        @token = JWT.encode payload, ENV["HMAC_SECRET"], 'HS256'
      end

      after(:example) do
        Guitar.delete_all
        session.clear
      end

      it 'successfully updates a guitar' do
        patch :update, params: { user_id: 1, id: 1, guitar: {model: 'after_update'}, token: @token }
        expect(Guitar.first.model).to eq('after_update')
      end

      it 'successfully updates multiple attributes' do
        patch :update, params: { user_id: 1, id: 1, guitar: {model: 'after_update', spec: 'after_spec'}, token: @token }
        expect(Guitar.first.model).to eq('after_update')
        expect(Guitar.first.spec).to eq('after_spec')
      end

      it 'renders JSON data after updating' do
        patch :update, params: { user_id: 1, id: 1, guitar: {model: 'after_update'}, token: @token }
        json_response = JSON.parse(response.body)
        expect(json_response["model"]).to eq('after_update')
      end

      it "renders 'model can't be blank' error message" do
        patch :update, params: { user_id: 1, id: 1, guitar: {model: ''}, token: @token }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"][0]).to eq("Model can't be blank")
      end

      it 'will not update if not logged in as the seller of the guitar' do
        session[:user_id] = 100
        patch :update, params: { user_id: 1, id: 1, guitar: {model: ''} }
        json_response = JSON.parse(response.body)
        expect(json_response["errors"]).to eq("You are not logged in")
      end
    end

    describe 'Delete #destroy' do

      it 'can successfully delete a guitar' do
        user = User.create(email: "test@email.com", username: 'test', password: "test123")
        user.guitars.build(model: "before_model", spec: "before_spec", price: 5, condition: "new", location: "somewhere").save
        delete :destroy, params: { user_id: 1, id: 1 }
        expect(Guitar.all.size).to eq(0)
      end

      it 'renders message when deleting a guitar' do
        user = User.create(email: "test@email.com", username: 'test', password: "test123")
        user.guitars.build(model: "before_model", spec: "before_spec", price: 5, condition: "new", location: "somewhere").save
        delete :destroy, params: { user_id: 1, id: 1 }
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("Guitar was deleted")
      end

      # it "renders an error when deleting a guitar that doesn't exist" do
      #   user = User.create(email: "test@email.com", username: 'test', password: "test123")
      #   user.guitars.build(model: "before_model", spec: "before_spec", price: 5, condition: "new", location: "somewhere").save
      #   delete :destroy, params: { user_id: 1, id: 100 }
      #   json_response = JSON.parse(response.body)
      #   expect(json_response["errors"]).to eq("There was an error")
      # end
    end
end
