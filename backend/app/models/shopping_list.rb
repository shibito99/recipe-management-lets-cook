class ShoppingList < ApplicationRecord
  has_many :shopping_items, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
end
