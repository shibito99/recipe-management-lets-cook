FactoryBot.define do
  factory :instruction do
    recipe
    step_number { 1 }
    body        { Faker::Lorem.sentence }
  end
end
