class Instruction < ApplicationRecord
  belongs_to :recipe

  validates :step_number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :body,        presence: true, length: { maximum: 300 }
  validates :step_number, uniqueness: { scope: :recipe_id }

  default_scope { order(:step_number) }
end
