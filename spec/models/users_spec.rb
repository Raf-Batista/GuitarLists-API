require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    # Shoulda-Matcher validations, see the docs for more info
    # https://github.com/thoughtbot/shoulda-matchers
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:password) }
    it { should have_secure_password }
    it { should have_many(:guitars) }

    it 'Should not create a username if it already exists' do
      User.create(email: 'first@email.com', password: 'abc123')
      second = User.create(email: 'first@email.com', password: 'abc123')

      expect(second.valid?).to eq(false)
    end

    it 'Should not create a username with a password less than 5 characters' do
      user = User.create(email: 'first@email.com', password: 'abc')

      expect(user.valid?).to eq(false)
    end
  end
end
