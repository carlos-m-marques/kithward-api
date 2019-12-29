class AddValuesToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_attributes, :values, :string, array: true
  end
end
