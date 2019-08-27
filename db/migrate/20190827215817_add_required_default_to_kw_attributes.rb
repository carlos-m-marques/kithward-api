class AddRequiredDefaultToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    change_column :kw_attributes, :required, :boolean, default: false
  end
end
