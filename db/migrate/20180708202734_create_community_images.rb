class CreateCommunityImages < ActiveRecord::Migration[5.2]
  def change
    create_table :community_images do |t|
      t.references :community
      t.string    :caption, limit: 1024
      t.string    :tags, limit: 1024

      t.timestamps
    end
  end
end
