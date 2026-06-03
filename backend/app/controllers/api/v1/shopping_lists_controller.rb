module Api
  module V1
    class ShoppingListsController < ApplicationController
      before_action :set_list, only: [:destroy]

      def index
        lists = ShoppingList.order(created_at: :desc)
        render json: { data: lists.map { |l| { id: l.id, name: l.name, created_at: l.created_at } } }
      end

      def create
        list = ShoppingList.create!(name: params[:name] || "マイリスト")
        render json: { data: { id: list.id, name: list.name } }, status: :created
      end

      def destroy
        @list.destroy!
        head :no_content
      end

      private

      def set_list
        @list = ShoppingList.find(params[:id])
      end
    end
  end
end
