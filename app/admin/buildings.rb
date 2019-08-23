ActiveAdmin.register Building do
  menu parent: 'Communities'

  permit_params :name, :community_id, :flagged_at, :flagged_for
end
