FactoryBot.define do
  factory :ingredient do
    recipe
    name       { Faker::Food.ingredient }
    amount     { rand(1..200).to_f }
    unit       { %w[g ml 個 大さじ 小さじ].sample }
    sort_order { 0 }
  end
end
