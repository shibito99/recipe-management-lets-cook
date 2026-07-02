require "rails_helper"

RSpec.describe "Api::V1::Recipes", type: :request do
  let(:valid_params) do
    {
      recipe: {
        title: "鶏の唐揚げ",
        genre: "japanese",
        servings: 2,
        cook_time: 30,
        description: "サクサクの唐揚げ",
        ingredients_attributes: [
          { name: "鶏もも肉", amount: 300, unit: "g", sort_order: 1 },
          { name: "醤油",     amount: 30,  unit: "ml", sort_order: 2 }
        ],
        instructions_attributes: [
          { step_number: 1, body: "鶏肉を一口大に切る" },
          { step_number: 2, body: "醤油で下味をつける" }
        ]
      }
    }
  end

  describe "GET /api/v1/recipes" do
    let!(:recipe1) { create(:recipe, title: "カレー",   genre: "western",  cook_time: 60) }
    let!(:recipe2) { create(:recipe, title: "親子丼",   genre: "japanese", cook_time: 20) }
    let!(:recipe3) { create(:recipe, title: "パスタ",   genre: "western",  cook_time: 25) }

    it "returns all recipes with pagination meta" do
      get "/api/v1/recipes"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].length).to eq(3)
      expect(json["meta"].keys).to contain_exactly("total", "page", "per_page")
    end

    it "filters by genre" do
      get "/api/v1/recipes", params: { genre: "japanese" }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("親子丼")
    end

    it "filters by keyword in title" do
      get "/api/v1/recipes", params: { q: "カレー" }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("カレー")
    end

    it "filters by keyword in description" do
      create(:recipe, title: "特製スープ", description: "トマトベースの濃厚スープ", genre: "western", cook_time: 40)
      get "/api/v1/recipes", params: { q: "トマト" }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("特製スープ")
    end

    it "filters by cook_time_max" do
      get "/api/v1/recipes", params: { cook_time_max: 30 }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("親子丼", "パスタ")
    end

    it "filters by ingredient name" do
      recipe_with_chicken = create(:recipe, title: "鶏の唐揚げ", genre: "japanese", cook_time: 30)
      create(:ingredient, recipe: recipe_with_chicken, name: "鶏もも肉")
      get "/api/v1/recipes", params: { ingredient: "鶏もも肉" }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("鶏の唐揚げ")
    end

    it "filters by tag_ids" do
      tag = create(:tag, name: "お弁当")
      recipe2.tags << tag
      get "/api/v1/recipes", params: { tag_ids: tag.id.to_s }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("親子丼")
    end

    it "filters by multiple tag_ids (OR condition)" do
      tag1 = create(:tag, name: "お弁当")
      tag2 = create(:tag, name: "簡単")
      recipe2.tags << tag1
      recipe3.tags << tag2
      get "/api/v1/recipes", params: { tag_ids: "#{tag1.id},#{tag2.id}" }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("親子丼", "パスタ")
    end

    it "combines genre and cook_time_max filters" do
      get "/api/v1/recipes", params: { genre: "western", cook_time_max: 30 }
      json = JSON.parse(response.body)
      expect(json["data"].map { |r| r["title"] }).to contain_exactly("パスタ")
    end

    context "sorting" do
      it "defaults to created_at desc (newest first)" do
        get "/api/v1/recipes"
        json = JSON.parse(response.body)
        titles = json["data"].map { |r| r["title"] }
        expect(titles.first).to eq("パスタ")
      end

      it "sorts by cook_time_asc" do
        get "/api/v1/recipes", params: { sort: "cook_time_asc" }
        json = JSON.parse(response.body)
        cook_times = json["data"].map { |r| r["cook_time"] }
        expect(cook_times).to eq(cook_times.sort)
      end

      it "sorts by title_asc" do
        get "/api/v1/recipes", params: { sort: "title_asc" }
        json = JSON.parse(response.body)
        titles = json["data"].map { |r| r["title"] }
        expect(titles).to eq(titles.sort)
      end

      it "sorts by created_at_asc (oldest first)" do
        get "/api/v1/recipes", params: { sort: "created_at_asc" }
        json = JSON.parse(response.body)
        titles = json["data"].map { |r| r["title"] }
        expect(titles.first).to eq("カレー")
      end
    end

    context "pagination" do
      it "returns per_page items and correct total in meta" do
        get "/api/v1/recipes", params: { per_page: 2 }
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(2)
        expect(json["meta"]["total"]).to eq(3)
        expect(json["meta"]["per_page"]).to eq(2)
      end

      it "returns the second page" do
        get "/api/v1/recipes", params: { per_page: 2, page: 2 }
        json = JSON.parse(response.body)
        expect(json["data"].length).to eq(1)
        expect(json["meta"]["page"]).to eq(2)
      end

      it "returns empty data for out-of-range page" do
        get "/api/v1/recipes", params: { per_page: 3, page: 99 }
        json = JSON.parse(response.body)
        expect(json["data"]).to be_empty
        expect(json["meta"]["total"]).to eq(3)
      end
    end
  end

  describe "GET /api/v1/recipes/:id" do
    let!(:recipe) { create(:recipe, :with_ingredients, :with_instructions) }

    it "returns the recipe detail" do
      get "/api/v1/recipes/#{recipe.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["id"]).to eq(recipe.id)
      expect(json["data"]["ingredients"]).to be_present
      expect(json["data"]["instructions"]).to be_present
    end

    it "returns 404 for unknown id" do
      get "/api/v1/recipes/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/recipes" do
    it "creates a recipe with nested attributes" do
      expect {
        post "/api/v1/recipes", params: valid_params, as: :json
      }.to change(Recipe, :count).by(1)
         .and change(Ingredient, :count).by(2)
         .and change(Instruction, :count).by(2)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["data"]["title"]).to eq("鶏の唐揚げ")
    end

    it "returns 422 when title is blank" do
      post "/api/v1/recipes", params: { recipe: valid_params[:recipe].merge(title: "") }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]["code"]).to eq("VALIDATION_ERROR")
    end

    it "returns 422 for invalid genre" do
      post "/api/v1/recipes", params: { recipe: valid_params[:recipe].merge(genre: "unknown") }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/recipes/:id" do
    let!(:recipe) { create(:recipe) }

    it "updates the recipe" do
      patch "/api/v1/recipes/#{recipe.id}",
            params: { recipe: { title: "更新タイトル" } },
            as: :json
      expect(response).to have_http_status(:ok)
      expect(recipe.reload.title).to eq("更新タイトル")
    end

    it "returns 404 for unknown id" do
      patch "/api/v1/recipes/999999", params: { recipe: { title: "x" } }, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/recipes/:id" do
    let!(:recipe) { create(:recipe, :with_ingredients) }

    it "deletes the recipe and its ingredients" do
      expect {
        delete "/api/v1/recipes/#{recipe.id}"
      }.to change(Recipe, :count).by(-1)
         .and change(Ingredient, :count).by(-3)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for unknown id" do
      delete "/api/v1/recipes/999999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
