class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name,       presence: true, length: { maximum: 100 }
  validates :sort_order, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount,     numericality: { greater_than: 0 }, allow_nil: true

  default_scope { order(:sort_order) }
end
