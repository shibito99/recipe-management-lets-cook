module Api
  module V1
    class ShoppingItemsController < ApplicationController
      before_action :set_list
      before_action :set_item, only: [:update, :destroy]

      def index
        items = @list.shopping_items.order(created_at: :asc)
        render json: { data: items.map { |i| item_json(i) } }
      end

      def create
        if params[:recipe_id].present?
          create_from_recipe
        else
          create_individual
        end
      end

      def update
        @item.update!(checked: params[:checked])
        render json: { data: item_json(@item) }
      end

      def destroy
        @item.destroy!
        head :no_content
      end

      # DELETE /api/v1/shopping_lists/:shopping_list_id/items/checked
      def checked
        @list.shopping_items.checked.destroy_all
        head :no_content
      end

      private

      def set_list
        @list = ShoppingList.find(params[:shopping_list_id])
      end

      def set_item
        @item = @list.shopping_items.find(params[:id])
      end

      def create_from_recipe
        recipe   = Recipe.find(params[:recipe_id])
        servings = params[:servings].to_i
        ratio    = servings.positive? ? servings.to_f / recipe.servings : 1.0

        items = recipe.ingredients.map do |ing|
          @list.shopping_items.create!(
            recipe:  recipe,
            name:    ing.name,
            amount:  ing.amount ? (ing.amount * ratio).round(1) : nil,
            unit:    ing.unit,
            checked: false
          )
        end

        render json: { data: items.map { |i| item_json(i) } }, status: :created
      end

      def create_individual
        items = Array(params[:items]).map do |item_params|
          @list.shopping_items.create!(
            name:    item_params[:name],
            amount:  item_params[:amount],
            unit:    item_params[:unit],
            checked: false
          )
        end

        render json: { data: items.map { |i| item_json(i) } }, status: :created
      end

      def item_json(item)
        {
          id:      item.id,
          name:    item.name,
          amount:  item.amount&.to_f,
          unit:    item.unit,
          checked: item.checked
        }
      end
    end
  end
end
