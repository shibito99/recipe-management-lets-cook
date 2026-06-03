FactoryBot.define do
  factory :recipe do
    title    { Faker::Food.dish }
    genre    { Recipe::GENRES.sample }
    servings { rand(1..6) }
    cook_time { rand(10..60) }
    description { Faker::Lorem.sentence }

    trait :with_ingredients do
      after(:create) do |recipe|
        create_list(:ingredient, 3, recipe: recipe)
      end
    end

    trait :with_instructions do
      after(:create) do |recipe|
        3.times { |i| create(:instruction, recipe: recipe, step_number: i + 1) }
      end
    end
  end
end
