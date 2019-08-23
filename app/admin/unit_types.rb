ActiveAdmin.register UnitType, as: 'Unit Layouts' do
  menu parent: 'Communities'

  permit_params :name, :community_id, :flagged_at, :flagged_for
end
