class AddUiTypeDefaultToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    change_column :kw_attributes, :ui_type, :string, default: 'select'
  end
end
