module Api
  module V1
    class TagsController < ApplicationController
      def index
        tags = Tag.order(:name)
        render json: { data: tags.map { |t| { id: t.id, name: t.name } } }
      end
    end
  end
end
