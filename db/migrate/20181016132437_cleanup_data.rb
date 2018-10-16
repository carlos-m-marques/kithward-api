class CleanupData < ActiveRecord::Migration[5.2]
  def change
    Community.with_data('amenity_ATM').find_each do |c|
      c.rename_data('amenity_ATM', 'amenity_atm')
      c.save
    end

    Community.with_data('care_RN').find_each do |c|
      c.rename_data('care_RN', 'care_rn')
      c.save
    end

    Community.with_data('care_LPN').find_each do |c|
      c.rename_data('care_LPN', 'care_lpn')
      c.save
    end

    Community.with_data('room_dettached').find_each do |c|
      c.rename_data('room_dettached', 'room_detached')
      c.save
    end

    remove_column :communities, :old_data
  end
end
