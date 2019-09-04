class CreateCommunityShareHit < ActiveRecord::Migration[5.2]
  def change
    create_table :community_share_hits do |t|
      t.references :community, foreign_key: true
      t.string :from
      t.string :tracking

      t.timestamps
    end
  end
end
