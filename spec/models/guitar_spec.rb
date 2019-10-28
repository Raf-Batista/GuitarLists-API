require 'rails_helper'

RSpec.describe Guitar, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:spec) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:condition) }
    it { should validate_presence_of(:location) }
    it { should belong_to(:user) }
  end
end
