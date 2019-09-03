class AddHiddenToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_attributes, :hidden, :boolean, default: false
    KwAttribute.update_all(hidden: false)
  end
end
