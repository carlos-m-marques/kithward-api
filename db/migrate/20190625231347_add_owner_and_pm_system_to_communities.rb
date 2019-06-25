class AddOwnerAndPmSystemToCommunities < ActiveRecord::Migration[5.2]
  def up
  	add_reference :communities, :owner, index: true, foreign_key: true
  	add_reference :communities, :pm_system, index: true, foreign_key: true
  	pm_system = PmSystem.find_by_name('PM System TBA') || PmSystem.create(name: 'PM System TBA')
  	owner = Owner.find_by_name('Owner TBA') || Owner.create(name: 'Owner TBA', pm_system: pm_system)
  	Community.all.update_all(owner_id: owner.id, pm_system_id: pm_system.id)
  	change_column_null :communities, :owner_id, false
  	change_column_null :communities, :pm_system_id, false
  end

  def down
  	remove_reference :communities, :owner, index: true, foreign_key: true
  	remove_reference :communities, :pm_system, index: true, foreign_key: true
  end
end
