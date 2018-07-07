class DeleteKeywords < ActiveRecord::Migration[5.2]
  def change
    drop_table :keywords
    drop_table :keyword_groups
    drop_table :facilities_keywords
  end
end
