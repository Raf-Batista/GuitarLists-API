class Guitar < ApplicationRecord
  belongs_to :user

  validates :model, presence: true
  validates :spec, presence: true
  validates :price, presence: true
  validates :condition, presence: true
  validates :location, presence: true
end
