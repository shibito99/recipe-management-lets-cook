require "rails_helper"

RSpec.describe "Api::V1::ShoppingLists", type: :request do
  describe "GET /api/v1/shopping_lists" do
    let!(:list1) { create(:shopping_list, name: "週末の買い物") }
    let!(:list2) { create(:shopping_list, name: "平日の買い物") }

    it "returns all shopping lists in descending order" do
      get "/api/v1/shopping_lists"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].length).to eq(2)
      expect(json["data"].first["name"]).to eq("平日の買い物")
    end

    it "includes id, name, created_at in each list" do
      get "/api/v1/shopping_lists"
      json = JSON.parse(response.body)
      json["data"].each do |list|
        expect(list.keys).to contain_exactly("id", "name", "created_at")
      end
    end
  end

  describe "POST /api/v1/shopping_lists" do
    it "creates a shopping list with given name" do
      post "/api/v1/shopping_lists", params: { name: "テストリスト" }
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["data"]["name"]).to eq("テストリスト")
    end

    it "creates a shopping list with default name when name is omitted" do
      post "/api/v1/shopping_lists"
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["data"]["name"]).to eq("マイリスト")
    end
  end

  describe "DELETE /api/v1/shopping_lists/:id" do
    let!(:list) { create(:shopping_list) }

    it "deletes the shopping list" do
      delete "/api/v1/shopping_lists/#{list.id}"
      expect(response).to have_http_status(:no_content)
      expect(ShoppingList.find_by(id: list.id)).to be_nil
    end

    it "returns 404 for unknown id" do
      delete "/api/v1/shopping_lists/99999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
