require "rails_helper"

RSpec.describe "Api::V1::Tags", type: :request do
  describe "GET /api/v1/tags" do
    let!(:tag_b) { create(:tag, name: "簡単") }
    let!(:tag_a) { create(:tag, name: "お弁当") }
    let!(:tag_c) { create(:tag, name: "ヘルシー") }

    it "returns all tags" do
      get "/api/v1/tags"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].length).to eq(3)
    end

    it "returns tags sorted by name" do
      get "/api/v1/tags"
      json = JSON.parse(response.body)
      names = json["data"].map { |t| t["name"] }
      expect(names).to eq(names.sort)
    end

    it "includes id and name in each tag" do
      get "/api/v1/tags"
      json = JSON.parse(response.body)
      json["data"].each do |tag|
        expect(tag.keys).to contain_exactly("id", "name")
      end
    end

    it "returns empty array when no tags exist" do
      Tag.delete_all
      get "/api/v1/tags"
      json = JSON.parse(response.body)
      expect(json["data"]).to be_empty
    end
  end
end
