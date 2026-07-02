require "rails_helper"

RSpec.describe "Api::V1::ShoppingItems", type: :request do
  let!(:list) { create(:shopping_list) }

  describe "GET /api/v1/shopping_lists/:shopping_list_id/items" do
    let!(:item1) { create(:shopping_item, shopping_list: list, name: "玉ねぎ") }
    let!(:item2) { create(:shopping_item, shopping_list: list, name: "にんじん") }

    it "returns all items in the shopping list" do
      get "/api/v1/shopping_lists/#{list.id}/items"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].length).to eq(2)
    end

    it "includes id, name, amount, unit, checked in each item" do
      get "/api/v1/shopping_lists/#{list.id}/items"
      json = JSON.parse(response.body)
      json["data"].each do |item|
        expect(item.keys).to contain_exactly("id", "name", "amount", "unit", "checked")
      end
    end

    it "returns 404 for unknown shopping list" do
      get "/api/v1/shopping_lists/99999/items"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/shopping_lists/:shopping_list_id/items (individual)" do
    it "creates individual items" do
      post "/api/v1/shopping_lists/#{list.id}/items", params: {
        items: [
          { name: "牛肉", amount: 300, unit: "g" },
          { name: "塩", amount: nil, unit: "適量" }
        ]
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["data"].map { |i| i["name"] }).to contain_exactly("牛肉", "塩")
    end

    it "creates items with checked: false by default" do
      post "/api/v1/shopping_lists/#{list.id}/items", params: {
        items: [{ name: "卵", amount: 6, unit: "個" }]
      }
      json = JSON.parse(response.body)
      expect(json["data"].first["checked"]).to be false
    end
  end

  describe "POST /api/v1/shopping_lists/:shopping_list_id/items (from recipe)" do
    let!(:recipe) do
      r = create(:recipe, servings: 2)
      create(:ingredient, recipe: r, name: "鶏もも肉", amount: 200, unit: "g")
      create(:ingredient, recipe: r, name: "醤油",     amount: 30,  unit: "ml")
      r
    end

    it "adds ingredients from a recipe" do
      post "/api/v1/shopping_lists/#{list.id}/items", params: {
        recipe_id: recipe.id, servings: 2
      }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["data"].map { |i| i["name"] }).to contain_exactly("鶏もも肉", "醤油")
    end

    it "scales amounts when servings differ" do
      post "/api/v1/shopping_lists/#{list.id}/items", params: {
        recipe_id: recipe.id, servings: 4
      }
      json = JSON.parse(response.body)
      chicken = json["data"].find { |i| i["name"] == "鶏もも肉" }
      expect(chicken["amount"]).to eq(400.0)
    end
  end

  describe "PATCH /api/v1/shopping_lists/:shopping_list_id/items/:id" do
    let!(:item) { create(:shopping_item, shopping_list: list, checked: false) }

    it "updates checked status to true" do
      patch "/api/v1/shopping_lists/#{list.id}/items/#{item.id}", params: { checked: true }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["checked"]).to be true
    end

    it "updates checked status to false" do
      item.update!(checked: true)
      patch "/api/v1/shopping_lists/#{list.id}/items/#{item.id}", params: { checked: false }
      json = JSON.parse(response.body)
      expect(json["data"]["checked"]).to be false
    end

    it "returns 404 for unknown item" do
      patch "/api/v1/shopping_lists/#{list.id}/items/99999", params: { checked: true }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/shopping_lists/:shopping_list_id/items/:id" do
    let!(:item) { create(:shopping_item, shopping_list: list) }

    it "deletes the item" do
      delete "/api/v1/shopping_lists/#{list.id}/items/#{item.id}"
      expect(response).to have_http_status(:no_content)
      expect(ShoppingItem.find_by(id: item.id)).to be_nil
    end

    it "returns 404 for unknown item" do
      delete "/api/v1/shopping_lists/#{list.id}/items/99999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/shopping_lists/:shopping_list_id/items/checked" do
    let!(:checked_item1) { create(:shopping_item, shopping_list: list, checked: true) }
    let!(:checked_item2) { create(:shopping_item, shopping_list: list, checked: true) }
    let!(:unchecked_item) { create(:shopping_item, shopping_list: list, checked: false) }

    it "deletes all checked items" do
      delete "/api/v1/shopping_lists/#{list.id}/items/checked"
      expect(response).to have_http_status(:no_content)
      expect(list.shopping_items.count).to eq(1)
      expect(list.shopping_items.first.checked).to be false
    end
  end
end
