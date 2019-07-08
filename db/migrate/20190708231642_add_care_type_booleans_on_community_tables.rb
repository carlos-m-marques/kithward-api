class AddCareTypeBooleansOnCommunityTables < ActiveRecord::Migration[5.2]
  def up
    attributes_to_create = [:is_care_type_il?, :is_care_type_al?, :is_care_type_sn?, :is_care_type_mc?, :is_care_type_un?]
    change_tables = [:community_classes, :community_attributes]

    change_tables.each do |ct|
      change_table ct do |t|
        t.remove :is_required
        attributes_to_create.each do |attrib|
          t.boolean attrib, null: false, default: false
        end
      end
    end
  end

  def down
    attributes_to_create = [:is_care_type_il?, :is_care_type_al?, :is_care_type_sn?, :is_care_type_mc?, :is_care_type_un?]
    change_tables = [:community_classes, :community_attributes]

    change_tables.each do |ct|
      change_table ct do |t|
        attributes_to_create.each do |attrib|
          t.remove attrib
        end
        t.boolean :is_required, null: false, default: false
      end
    end
  end
end
