FactoryBot.define do
  factory :shopping_list do
    sequence(:name) { |n| "買い物リスト#{n}" }
  end
end
