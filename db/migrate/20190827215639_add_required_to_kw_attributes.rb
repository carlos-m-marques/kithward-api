class AddRequiredToKwAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :kw_attributes, :required, :boolean
  end
end
