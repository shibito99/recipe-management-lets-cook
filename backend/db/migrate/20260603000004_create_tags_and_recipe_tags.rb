class CreateTagsAndRecipeTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false, limit: 20
      t.timestamps null: false
    end
    add_index :tags, :name, unique: true

    create_table :recipe_tags do |t|
      t.references :recipe, null: false, foreign_key: { on_delete: :cascade }
      t.references :tag,    null: false, foreign_key: { on_delete: :cascade }
      t.timestamps null: false
    end
    add_index :recipe_tags, [:recipe_id, :tag_id], unique: true
  end
end
