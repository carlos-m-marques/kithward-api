class AddIntercomDataToLeads < ActiveRecord::Migration[5.2]
  def change
    add_column :leads, :data, :jsonb
  end
end
