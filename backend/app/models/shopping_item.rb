class ShoppingItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :recipe, optional: true

  validates :name,    presence: true, length: { maximum: 100 }
  validates :checked, inclusion: { in: [true, false] }
  validates :amount,  numericality: { greater_than: 0 }, allow_nil: true

  scope :unchecked, -> { where(checked: false) }
  scope :checked,   -> { where(checked: true) }
end
