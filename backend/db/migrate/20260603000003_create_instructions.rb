class CreateInstructions < ActiveRecord::Migration[7.2]
  def change
    create_table :instructions do |t|
      t.references :recipe,      null: false, foreign_key: { on_delete: :cascade }
      t.integer    :step_number, null: false
      t.text       :body,        null: false
      t.string     :image_key

      t.timestamps null: false
    end

    add_index :instructions, [:recipe_id, :step_number], unique: true
  end
end
