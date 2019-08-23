ActiveAdmin.register Unit do
  menu parent: 'Communities'

  permit_params :name, :is_available, :date_available, :rent_market, :unit_number, :building_id, :unit_type_id, :flagged_at, :flagged_for
end
