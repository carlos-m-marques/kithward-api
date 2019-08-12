class AddUiTypeToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_attributes, :ui_type, :string
    add_index :kw_attributes, :ui_type
  end
end
