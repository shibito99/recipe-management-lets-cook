FactoryBot.define do
  factory :shopping_item do
    association :shopping_list
    sequence(:name) { |n| "食材#{n}" }
    amount { 1.0 }
    unit   { "個" }
    checked { false }
  end
end
