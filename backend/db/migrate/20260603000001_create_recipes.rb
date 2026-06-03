class CreateRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipes do |t|
      t.string  :title,       null: false, limit: 100
      t.text    :description
      t.string  :genre,       null: false, default: "other"
      t.integer :servings,    null: false, default: 1
      t.integer :cook_time
      t.string  :image_key

      t.timestamps null: false
    end

    add_index :recipes, :genre
    add_index :recipes, :cook_time
  end
end
